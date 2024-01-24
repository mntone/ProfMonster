
public enum Physical: UInt8, CaseIterable {
	case slash = 0x01
	case impact = 0x02
	case shot = 0x04

	public var key: String {
		switch self {
		case .slash:
			"slash"
		case .impact:
			"impact"
		case .shot:
			"shot"
		}
	}
}

public enum Element: UInt8, CaseIterable {
	case fire = 0x08
	case water = 0x10
	case thunder = 0x20
	case ice = 0x40
	case dragon = 0x80

	public var key: String {
		switch self {
		case .fire:
			"fire"
		case .water:
			"water"
		case .thunder:
			"thunder"
		case .ice:
			"ice"
		case .dragon:
			"dragon"
		}
	}
}

public enum ContextualAttack {
	case physical(Physical)
	case element(Element)
}

public enum Attack: UInt8, CaseIterable {
	case slash = 0x01
	case impact = 0x02
	case shot = 0x04

	case fire = 0x08
	case water = 0x10
	case thunder = 0x20
	case ice = 0x40
	case dragon = 0x80

	init(_ physical: Physical) {
		self = Attack(rawValue: physical.rawValue)!
	}

	init(_ element: Element) {
		self = Attack(rawValue: element.rawValue)!
	}

	public var key: String {
		switch self {
		case .slash:
			"slash"
		case .impact:
			"impact"
		case .shot:
			"shot"
		case .fire:
			"fire"
		case .water:
			"water"
		case .thunder:
			"thunder"
		case .ice:
			"ice"
		case .dragon:
			"dragon"
		}
	}

	public var contextual: ContextualAttack {
		switch self {
		case .slash:
			.physical(.slash)
		case .impact:
			.physical(.impact)
		case .shot:
			.physical(.shot)
		case .fire:
			.element(.fire)
		case .water:
			.element(.water)
		case .thunder:
			.element(.thunder)
		case .ice:
			.element(.ice)
		case .dragon:
			.element(.dragon)
		}
	}

	public var isPhysical: Bool {
		switch self {
		case .slash, .impact, .shot:
			true
		default:
			false
		}
	}

	public var isElement: Bool {
		switch self {
		case .fire, .water, .thunder, .ice, .dragon:
			true
		default:
			false
		}
	}

	public static let allPhysicals: [Attack] = [.slash, .impact, .shot]
	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}
