import Foundation
import SwiftUI

enum ViewModelError {
	case noConnection
	case timeout
	case notFound
	case other(Error)

	var key: String {
		switch self {
		case .noConnection:
			return "noConnection"
		case .timeout:
			return "timeout"
		case .notFound:
			return "notFound"
		case .other:
			return "other"
		}
	}

	var localizationValue: String.LocalizationValue {
		switch self {
		case .noConnection:
			return String.LocalizationValue("error.noConnection")
		case .timeout:
			return String.LocalizationValue("error.timeout")
		case .notFound:
			return String.LocalizationValue("error.notFound")
		case let .other(error):
			return String.LocalizationValue("error.other(\(error.localizedDescription))")
		}
	}
}
