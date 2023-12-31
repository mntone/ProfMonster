import Combine
import struct Foundation.Date
import enum MonsterAnalyzerCore.StarSwingsError
import enum MonsterAnalyzerCore.StarSwingsState

enum RequestState {
	case ready
	case loading
	case complete
	case failure(date: Date, error: StarSwingsError)

	var isReady: Bool {
		if case .ready = self {
			true
		} else {
			false
		}
	}

	var isLoading: Bool {
		if case .loading = self {
			true
		} else {
			false
		}
	}

	var hasError: Bool {
		if case .failure = self {
			true
		} else {
			false
		}
	}
}

extension StarSwingsState {
	@inline(__always)
	func removeData() -> RequestState {
		switch self {
		case .ready:
			.ready
		case .loading:
			.loading
		case .complete:
			.complete
		case let .failure(date: date, error: error):
			.failure(date: date, error: error)
		}
	}
}

extension Publisher {
	@inline(__always)
	func removeData<T>() -> Publishers.Map<Self, RequestState> where Self.Output == StarSwingsState<T> {
		map { state in
			state.removeData()
		}
	}
}
