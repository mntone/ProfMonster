
public enum Attack: UInt8, CaseIterable {
	case slash = 0x01
	case impact = 0x02
	case shot = 0x04

	case fire = 0x08
	case water = 0x10
	case thunder = 0x20
	case ice = 0x40
	case dragon = 0x80

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

	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}
