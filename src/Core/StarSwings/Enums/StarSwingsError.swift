import Foundation

public enum StarSwingsError: Error {
	case cancelled
	case connectionLost
	case noConnection
	case timedOut
	case notExists
	case notSupported
	case other(Error)
}

extension StarSwingsError: Equatable {
	public static func ==(lhs: StarSwingsError, rhs: StarSwingsError) -> Bool {
		switch (lhs, rhs) {
		case (.cancelled, .cancelled),
			(.connectionLost, .connectionLost),
			(.noConnection, .noConnection),
			(.timedOut, .timedOut),
			(.notExists, .notExists),
			(.notSupported, .notSupported):
			return true
		default:
			return false
		}
	}
}
