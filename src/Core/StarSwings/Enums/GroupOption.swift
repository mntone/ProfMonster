import class Foundation.UserDefaults

public enum GroupOption: String, CaseIterable, Hashable {
	case none = "None"
	case type = "Type"
	case weakness = "Weakness"

	public var isNone: Bool {
		self == .none
	}

	public var isType: Bool {
		self == .type
	}

	public var isWeakness: Bool {
		self == .weakness
	}
}

extension GroupOption: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: GroupOption {
		.none
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return GroupOption(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}
