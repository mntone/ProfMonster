import Foundation

public enum StarSwingsState {
	case ready
	case loading
	case complete
	case failure(date: Date, error: Error)
}
