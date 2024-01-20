
public enum Mode {
	case lowAndHigh
	case master
	case rankG
	case other(name: String)

	public init(rawValue: String) {
		switch rawValue {
		case "default":
			self = .lowAndHigh
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
		case .master:
			"master"
		case .rankG:
			"rank_g"
		case let .other(name):
			name
		}
	}
}
