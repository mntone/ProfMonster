import Foundation

public enum Sort: CaseIterable, Hashable {
	case inGame(reversed: Bool)
	case name(reversed: Bool)
	case type(reversed: Bool)
	case weakness(reversed: Bool)

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
		case "Type":
			self = .type(reversed: false)
		case "TypeDesc":
			self = .type(reversed: true)
		case "Weakness":
			self = .weakness(reversed: false)
		case "WeaknessDesc":
			self = .weakness(reversed: true)
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
		case .type(false):
			return "Type"
		case .type(true):
			return "TypeDesc"
		case .weakness(false):
			return "Weakness"
		case .weakness(true):
			return "WeaknessDesc"
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

	public var isType: Bool {
		if case .type = self {
			true
		} else {
			false
		}
	}

	public var isWeakness: Bool {
		if case .weakness = self {
			true
		} else {
			false
		}
	}

	public var isReversed: Bool {
		switch self {
		case .inGame(true), .name(true), .type(true), .weakness(true):
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
		case .type(false):
			.type(reversed: true)
		case .type(true):
			.type(reversed: false)
		case .weakness(false):
			.weakness(reversed: true)
		case .weakness(true):
			.weakness(reversed: false)
		}
	}

	public static func allOrderCases(reversed: Bool) -> [Sort] {
		reversed ? allDescendingCases : allAscendingCases
	}

	public static var allAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false),
		.type(reversed: false),
		.weakness(reversed: false),
	]

	public static var allDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true),
		.type(reversed: true),
		.weakness(reversed: true),
	]

	public static var allCases: [Sort] = [
		.inGame(reversed: false),
		.inGame(reversed: true),
		.name(reversed: false),
		.name(reversed: true),
		.type(reversed: false),
		.type(reversed: true),
		.weakness(reversed: false),
		.weakness(reversed: true),
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
