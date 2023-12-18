import Foundation

public enum StarSwingsState {
	case ready
	case loading
	case complete
	case failure(date: Date, error: StarSwingsError)

	public var hasError: Bool {
		if case .failure = self {
			true
		} else {
			false
		}
	}
}
