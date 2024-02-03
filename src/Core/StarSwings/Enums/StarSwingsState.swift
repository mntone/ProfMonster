import Combine
import Foundation

public enum StarSwingsState<Data> {
	case ready
	case loading(publisher: Publishers.Buffer<Deferred<PassthroughSubject<Data?, StarSwingsError>>>)
	case complete(data: Data)
	case failure(reset: Date, error: StarSwingsError)

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
