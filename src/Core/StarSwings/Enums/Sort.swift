import class Foundation.UserDefaults

public enum Sort: CaseIterable, Hashable {
	case inGame(reversed: Bool)
	case name(reversed: Bool, linked: Bool)
	@available(watchOS, unavailable)
	case size(reversed: Bool)

	public init?(rawValue: String) {
		switch rawValue {
		case "GAME":
			self = .inGame(reversed: false)
		case "GAME_REV":
			self = .inGame(reversed: true)
		case "NAME":
			self = .name(reversed: false, linked: true)
		case "NAME_REV":
			self = .name(reversed: true, linked: true)
		case "NAME_NOLINK":
			self = .name(reversed: false, linked: false)
		case "NAME_NOLINK_REV":
			self = .name(reversed: true, linked: false)
#if !os(watchOS)
		case "SIZE":
			self = .size(reversed: false)
		case "SIZE_REV":
			self = .size(reversed: true)
#endif
		default:
			return nil
		}
	}

	public var rawValue: String {
		switch self {
		case .inGame(false):
			return "GAME"
		case .inGame(true):
			return "GAME_REV"
		case .name(false, true):
			return "NAME"
		case .name(true, true):
			return "NAME_REV"
		case .name(false, false):
			return "NAME_NOLINK"
		case .name(true, false):
			return "NAME_NOLINK_REV"
#if !os(watchOS)
		case .size(false):
			return "SIZE"
		case .size(true):
			return "SIZE_REV"
#endif
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

#if !os(watchOS)
	public var isSize: Bool {
		if case .size = self {
			true
		} else {
			false
		}
	}
#endif

	public var isReversed: Bool {
		switch self {
#if os(watchOS)
		case .inGame(true), .name(true, _):
			true
#else
		case .inGame(true), .name(true, _), .size(true):
			true
#endif
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
		case let .name(false, linked):
			.name(reversed: true, linked: linked)
		case let .name(true, linked):
			.name(reversed: false, linked: linked)
#if !os(watchOS)
		case .size(false):
			.size(reversed: true)
		case .size(true):
			.size(reversed: false)
#endif
		}
	}

	public var isLinked: Bool {
		switch self {
		case let .name(_, linked):
			linked
		default:
			true
		}
	}

	public func toggleLinked() -> Self {
		switch self {
		case let .name(reversed, linked):
			.name(reversed: reversed, linked: !linked)
		default:
			self
		}
	}

	public static func allOrderCases(reversed: Bool, linked: Bool) -> [Sort] {
		reversed
			? (linked ? allDescendingCases : allSimpleDescendingCases)
			: (linked ? allAscendingCases : allSimpleAscendingCases)
	}

#if os(watchOS)
	public static var allAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false, linked: true),
	]

	public static var allSimpleAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false, linked: false),
	]

	public static var allDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true, linked: true),
	]

	public static var allSimpleDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true, linked: false),
	]

	public static var allCases: [Sort] = [
		.inGame(reversed: false),
		.inGame(reversed: true),
		.name(reversed: false, linked: true),
		.name(reversed: true, linked: true),
		.name(reversed: false, linked: false),
		.name(reversed: true, linked: false),
	]
#else
	public static var allAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false, linked: true),
		.size(reversed: false),
	]

	public static var allSimpleAscendingCases: [Sort] = [
		.inGame(reversed: false),
		.name(reversed: false, linked: false),
		.size(reversed: false),
	]

	public static var allDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true, linked: true),
		.size(reversed: true),
	]

	public static var allSimpleDescendingCases: [Sort] = [
		.inGame(reversed: true),
		.name(reversed: true, linked: false),
		.size(reversed: true),
	]

	public static var allCases: [Sort] = [
		.inGame(reversed: false),
		.inGame(reversed: true),
		.name(reversed: false, linked: true),
		.name(reversed: true, linked: true),
		.name(reversed: false, linked: false),
		.name(reversed: true, linked: false),
		.size(reversed: false),
		.size(reversed: true),
	]
#endif
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
