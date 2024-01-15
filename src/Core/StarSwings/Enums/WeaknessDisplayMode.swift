import Foundation

public enum WeaknessDisplayMode: CaseIterable, Hashable {
	case none
	case sign
	case number
	case number2

	public init?(rawValue: String) {
		switch rawValue {
		case "None":
			self = .none
		case "Number":
			self = .number
		case "Number2":
			self = .number2
		case "Sign":
			fallthrough
		default:
			self = .sign
		}
	}

	public var rawValue: String {
		switch self {
		case .none:
			return "None"
		case .sign:
			return "Sign"
		case .number:
			return "Number"
		case .number2:
			return "Number2"
		}
	}
}

extension WeaknessDisplayMode: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: WeaknessDisplayMode {
		.sign
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return WeaknessDisplayMode(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}
