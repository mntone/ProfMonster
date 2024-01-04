import SwiftUI

enum Effective: Int8 {
	case high = 20
	case middle = 10
	case low = 5
	case invalid = 0

	var label: String {
		switch self {
		case .high:
			String(localized: "+++", comment: "Effective/High")
		case .middle:
			String(localized: "++", comment: "Effective/Middle")
		case .low:
			String(localized: "+", comment: "Effective/Low")
		case .invalid:
			String(localized: "0", comment: "Effective/Invalid")
		}
	}

	var accessibilityLabel: String {
		switch self {
		case .high:
			String(localized: "High", comment: "Effective/High (Accessibility)")
		case .middle:
			String(localized: "Middle", comment: "Effective/Middle (Accessibility)")
		case .low:
			String(localized: "Low", comment: "Effective/Low (Accessibility)")
		case .invalid:
			String(localized: "Invalid", comment: "Effective/Invalid (Accessibility)")
		}
	}
}
