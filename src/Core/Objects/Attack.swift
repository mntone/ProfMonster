import Foundation

public enum Attack: String, CaseIterable {
	case slash
	case strike
	case shell

	case fire
	case water
	case thunder
	case ice
	case dragon

	public static let allElements: [Attack] = [.fire, .water, .thunder, .ice, .dragon]
}

extension Attack {
	var keyPathForMonsterPhysiologyValue: KeyPath<MHMonsterPhysiologyValue, Int8> {
		switch self {
		case .slash:
			return \.slash
		case .strike:
			return \.strike
		case .shell:
			return \.shell
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
