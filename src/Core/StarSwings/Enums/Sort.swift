import class Foundation.UserDefaults

public enum Sort: CaseIterable, Hashable {
	case inGame(reversed: Bool)
	case name(reversed: Bool)

	public init?(rawValue: String) {
		switch rawValue {
		case "InGame":
			self = .inGame(reversed: false)
		case "InGameDesc":
			self = .inGame(reversed: true)
		case "Name":
			self = .name(reversed: false)
		case "NameDesc":
			self = .name(reversed: true)
		default:
			return nil
		}
	}

	public var rawValue: String {
		switch self {
		case .inGame(false):
			return "InGame"
		case .inGame(true):
			return "InGameDesc"
		case .name(false):
			return "Name"
		case .name(true):
			return "NameDesc"
		}
	}

	public var isInGame: Bool {
		if case .inGame = self {
			true
		} else {
			false
		}
	}

	public var isName: Bool {
		if case .name = self {
			true
		} else {
			false
		}
	}

	public var isReversed: Bool {
		switch self {
		case .inGame(true), .name(true):
			true
		default:
			false
		}
	}

	public func reversed() -> Self {
		switch self {
		case .inGame(false):
			.inGame(reversed: true)
		case .inGame(true):
			.inGame(reversed: false)
		case .name(false):
			.name(reversed: true)
		case .name(true):
			.name(reversed: false)
		}
	}

	public static func allOrderCases(reversed: Bool) -> [Sort] {
		reversed ? allDescendingCases : allAscendingCases
	}

	public static var allAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false),
	]

	public static var allDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true),
	]

	public static var allCases: [Sort] = [
		.inGame(reversed: false),
		.inGame(reversed: true),
		.name(reversed: false),
		.name(reversed: true),
	]
}

extension Sort: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: Sort {
		.inGame(reversed: false)
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return Sort(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}
