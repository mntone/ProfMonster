import Combine
import Foundation

public class FetchableEntity<Data> {
	let _dataSource: DataSource
	let requestBehavior: RepeatBehavior
	let _lock: Lock = LockUtil.create()

#if DEBUG
	let delayRequest: Bool
#endif

	private(set) var retryCount: UInt = 0

	@Published
	public internal(set) var state: StarSwingsState<Data> = .ready

	var requireReset: Bool {
		true
	}

#if DEBUG
	init(dataSource: DataSource,
		 requestBehavior: RepeatBehavior,
		 delayed delayRequest: Bool) {
		self._dataSource = dataSource
		self.requestBehavior = requestBehavior
		self.delayRequest = delayRequest
	}
#else
	init(dataSource: DataSource,
		 requestBehavior: RepeatBehavior) {
		self._dataSource = dataSource
		self.requestBehavior = requestBehavior
	}
#endif

	public final func fetchIfNeeded() {
		Task {
			try await fetch(priority: .utility)
		}
	}

	public final func fetch() async throws -> Data? {
		try await fetch(priority: .utility)
	}

	final func fetch(priority: TaskPriority) async throws -> Data? {
		_lock.lock()

		switch state {
		case let .loading(publisher):
			_lock.unlock()
			return try await publisher.value
		case let .complete(data):
			_lock.unlock()
			return data
		case let .failure(reset, _):
			guard reset <= Date.now else {
				_lock.unlock()
				return nil
			}
			fallthrough
		case .ready:
			let publisher = Deferred { [weak self] () in
				let subject = PassthroughSubject<Data?, StarSwingsError>()
				Task.detached(priority: priority) { [weak self] in
					guard let self else {
						subject.send(completion: .failure(.cancelled))
						return
					}

#if DEBUG
					if delayRequest {
						try? await Task.sleep(nanoseconds: 1_500_000_000)
					}
#endif

					do {
						let data = try await _fetch()
						self._lock.withLock {
							self.retryCount = 0
							self.state = .complete(data: data)
						}
						subject.send(data)
						subject.send(completion: .finished)
					} catch {
						let ssError = _handle(error: error)
						subject.send(completion: .failure(ssError))
					}
				}
				return subject
			}
			.buffer(size: 1, prefetch: .keepFull, whenFull: .dropOldest)
			state = .loading(publisher: publisher)
			_lock.unlock()
			return try await publisher.value
		}
	}

	func _fetch() async throws -> Data {
		preconditionFailure("This function must be override.")
	}

	final func _handle(error: Error) -> StarSwingsError {
#if DEBUG
		debugPrint(error)
#endif

		let retError: StarSwingsError
		if let urlError = error as? URLError {
			retError = _handle(urlError: urlError)
		} else if let ssError = error as? StarSwingsError {
			retError = ssError
			_handle(ssError: ssError)
		} else {
			retError = .other(error)
			_handle(ssError: retError)
		}
		return retError
	}

	final func _handle(urlError: URLError) -> StarSwingsError {
#if DEBUG
		debugPrint(urlError)
#endif

		let ssError: StarSwingsError
		switch urlError.code {
		case .cancelled:
			ssError = .cancelled
		case .networkConnectionLost:
			ssError = .connectionLost
		case .cannotConnectToHost, .notConnectedToInternet, .dataNotAllowed:
			ssError = .noConnection
		case .timedOut:
			ssError = .timedOut
		case .fileDoesNotExist:
			ssError = .notExists
		default:
			ssError = .other(urlError)
		}
		_handle(ssError: ssError)
		return ssError
	}

	final func _handle(ssError: StarSwingsError) {
		let nextReset = Date.now + requestBehavior.timeInterval(retry: retryCount)
		_lock.withLock {
			retryCount = retryCount + 1
			state = .failure(reset: nextReset, error: ssError)
		}
	}

	final func resetState() {
		guard requireReset else { return }

		_lock.withLock {
			if case .complete = state {
				_resetChildStates()
				state = .ready
			}
		}
	}

	func _resetChildStates() {
	}
}
