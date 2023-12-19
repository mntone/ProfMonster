import Foundation

public enum StarSwingsError: Error {
	case cancelled
	case connectionLost
	case noConnection
	case timedOut
	case notExist
	case other(Error)
}

extension StarSwingsError: Equatable {
	public static func ==(lhs: StarSwingsError, rhs: StarSwingsError) -> Bool {
		switch (lhs, rhs) {
		case (.cancelled, .cancelled),
			(.connectionLost, .connectionLost),
			(.noConnection, .noConnection),
			(.timedOut, .timedOut),
			(.notExist, .notExist):
			return true
		default:
			return false
		}
	}
}
