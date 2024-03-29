
public enum Mode {
	case lowAndHigh
	case high
	case master
	case rankG
	case other(name: String)

	public init(rawValue: String) {
		switch rawValue {
		case "default":
			self = .lowAndHigh
		case "high":
			self = .high
		case "master":
			self = .master
		case "rank_g":
			self = .rankG
		default:
			self = .other(name: rawValue)
		}
	}

	public var rawValue: String {
		switch self {
		case .lowAndHigh:
			"default"
		case .high:
			"high"
		case .master:
			"master"
		case .rankG:
			"rank_g"
		case let .other(name):
			name
		}
	}

	public var isMasterOrG: Bool {
		switch self {
		case .master, .rankG:
			true
		default:
			false
		}
	}
}
