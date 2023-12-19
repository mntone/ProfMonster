import Combine
import Foundation

public enum StarSwingsState<Data> {
	case ready
	case loading
	case complete(data: Data)
	case failure(date: Date, error: StarSwingsError)

	public var isReady: Bool {
		if case .ready = self {
			true
		} else {
			false
		}
	}

	public var isLoading: Bool {
		if case .loading = self {
			true
		} else {
			false
		}
	}

	public var hasError: Bool {
		if case .failure = self {
			true
		} else {
			false
		}
	}

	public var data: Data? {
		if case let .complete(data) = self {
			data
		} else {
			nil
		}
	}
}

public extension StarSwingsState {
	func mapData<T>(_ transform: (Data) throws -> T) rethrows -> StarSwingsState<T> {
		switch self {
		case .ready:
			return .ready
		case .loading:
			return .loading
		case let .complete(data):
			return .complete(data: try transform(data))
		case let .failure(date: date, error: error):
			return .failure(date: date, error: error)
		}
	}
}

public extension Publisher {
	func mapData<T, U>(_ transform: @escaping (T) -> U) -> Publishers.Map<Self, StarSwingsState<U>> where Self.Output == StarSwingsState<T> {
		map { state in
			switch state {
			case .ready:
				return .ready
			case .loading:
				return .loading
			case let .complete(data):
				return .complete(data: transform(data))
			case let .failure(date: date, error: error):
				return .failure(date: date, error: error)
			}
		}
	}
}
