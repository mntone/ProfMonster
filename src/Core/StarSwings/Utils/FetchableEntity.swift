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
		let needToFetch = _lock.withLock {
			guard case .ready = state else { return false }
			state = .loading
			return true
		}
		guard needToFetch else { return }
		fetch(priority: .userInitiated)
	}

	@discardableResult
	final func fetch(priority: TaskPriority) -> Task<Data?, Never> {
		return Task.detached(priority: priority) { [weak self] in
			guard let self else { return nil }
			do {
				let data = try await _fetch()
				_lock.withLock {
					self.state = .complete(data: data)
				}
				return data
			} catch {
				_handle(error: error)
				return nil
			}
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
