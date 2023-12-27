import MonsterAnalyzerCore
import SwiftUI

extension StarSwingsError {
	var label: LocalizedStringKey {
		switch self {
		case .cancelled:
			return LocalizedStringKey("ERROR_CANCELLED")
		case .connectionLost:
			return LocalizedStringKey("ERROR_CONNECTION_LOST")
		case .noConnection:
			return LocalizedStringKey("ERROR_NO_CONNECTION")
		case .timedOut:
			return LocalizedStringKey("ERROR_TIMED_OUT")
		case .notExists:
			return LocalizedStringKey("ERROR_NOT_EXISTS")
		case .notSupported:
			return LocalizedStringKey("ERROR_NOT_SUPPORTED")
		case let .other(error):
			return LocalizedStringKey("ERROR_OTHER(\(error.localizedDescription))")
		}
	}
}
