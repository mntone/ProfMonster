import Combine
import Foundation

public class FetchableEntity<Data> {
	let _dataSource: DataSource
	let _lock: Lock = LockUtil.create()

	@Published
	public internal(set) var state: StarSwingsState<Data> = .ready

	init(dataSource: DataSource) {
		self._dataSource = dataSource
	}

	public final func fetchIfNeeded() {
		Task {
			await fetch(priority: .utility)
		}
	}

	public final func fetch() async -> Data? {
		await fetch(priority: .utility)
	}

	final func fetch(priority: TaskPriority) async -> Data? {
		_lock.lock()

		switch state {
		case let .loading(task):
			_lock.unlock()
			return await task.value
		case let .complete(data):
			_lock.unlock()
			return data
		case .ready, .failure:
			let task = Task.detached(priority: priority) { [weak self] () -> Data? in
				guard let self else { return nil }
				do {
					let data = try await _fetch()
					self._lock.withLock {
						self.state = .complete(data: data)
					}
					return data
				} catch {
					_handle(error: error)
					return nil
				}
			}
			state = .loading(task: task)
			_lock.unlock()
			return await task.value
		}
	}

	func _fetch() async throws -> Data {
		preconditionFailure("This function must be override.")
	}

	func _handle(error: Error) {
#if DEBUG
		debugPrint(error)
#endif

		if let urlError = error as? URLError {
			_handle(urlError: urlError)
		} else if let ssError = error as? StarSwingsError {
			_handle(ssError: ssError)
		} else {
			_handle(ssError: .other(error))
		}
	}

	func _handle(urlError: URLError) {
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
	}

	func _handle(ssError: StarSwingsError) {
		_lock.withLock {
			state = .failure(date: Date.now, error: ssError)
		}
	}
}
