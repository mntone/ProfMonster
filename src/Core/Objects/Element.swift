import Foundation

public enum Element: String, CaseIterable {
	case fire
	case water
	case thunder
	case ice
	case dragon
}

public extension Element {
	var keyPathForMonsterPhysiologyValue: KeyPath<MHMonsterPhysiologyValue, Int8> {
		switch self {
		case .fire:
			return \.fire
		case .water:
			return \.water
		case .thunder:
			return \.thunder
		case .ice:
			return \.ice
		case .dragon:
			return \.dragon
		}
	}
}
