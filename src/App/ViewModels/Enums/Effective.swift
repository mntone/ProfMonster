import SwiftUI

enum Effective: String {
	case high = "+++"
	case middle = "++"
	case low = "+"
	case none = "0"

	var localizedKey: LocalizedStringKey {
		LocalizedStringKey(rawValue)
	}
}
