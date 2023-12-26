import SwiftUI

enum Effective: String {
	case high = "+++"
	case middle = "++"
	case low = "+"
	case none = "0"

	var label: LocalizedStringKey {
		LocalizedStringKey(rawValue)
	}

	var accessibilityLabel: LocalizedStringKey {
		switch self {
		case .high:
			LocalizedStringKey("High")
		case .middle:
			LocalizedStringKey("Middle")
		case .low:
			LocalizedStringKey("Low")
		case .none:
			LocalizedStringKey("None")
		}
	}
}
