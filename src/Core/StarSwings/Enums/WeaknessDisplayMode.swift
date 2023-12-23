import Foundation

public enum WeaknessDisplayMode: String, CaseIterable, Identifiable, UserDefaultable {
	case none = "Off"
	case sign = "Sign"
	case number = "Number"

	public var id: String {
		rawValue
	}
}
