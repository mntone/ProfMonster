import SwiftUI

enum Effective: Int8 {
	case high = 20
	case middle = 10
	case low = 5
	case invalid = 0

	var label: String {
		switch self {
		case .high:
			String(localized: "+++", comment: "Effective")
		case .middle:
			String(localized: "++", comment: "Effective")
		case .low:
			String(localized: "+", comment: "Effective")
		case .invalid:
			String(localized: "0", comment: "Effective")
		}
	}

	var accessibilityLabel: String {
		switch self {
		case .high:
			String(localized: "High", comment: "Effective/Accessibility")
		case .middle:
			String(localized: "Middle", comment: "Effective/Accessibility")
		case .low:
			String(localized: "Low", comment: "Effective/Accessibility")
		case .invalid:
			String(localized: "Invalid", comment: "Effective/Accessibility")
		}
	}
}
