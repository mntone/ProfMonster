import Combine
import Foundation

public class FetchableEntity {
	let _dataSource: MHDataSource
	let _lock: Lock = LockUtil.create()

	var cancellable: AnyCancellable?

	@Published
	public var state: StarSwingsState = .ready

	init(dataSource: MHDataSource) {
		self._dataSource = dataSource
	}

	func _handle(completion: Subscribers.Completion<Error>) {
		switch completion {
		case let .failure(error):
			_handle(error: error)
		case .finished:
			state = .complete
		}
	}

	func _handle(error: Error) {
#if DEBUG
		debugPrint(error)
#endif

		if let urlError = error as? URLError {
			_handle(urlError: urlError)
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
			ssError = .notExist
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
