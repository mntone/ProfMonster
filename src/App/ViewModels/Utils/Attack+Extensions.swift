import MonsterAnalyzerCore
import SwiftUI

extension Attack {
	var color: Color {
		switch self {
		case .slash, .strike, .shell:
			return .primary
		case .fire:
			return .fire
		case .water:
			return .water
		case .thunder:
			return .thunder
		case .ice:
			return .ice
		case .dragon:
			return .dragon
		}
	}

	var imageName: String {
		switch self {
		case .slash:
			return "scissors"
		case .strike:
			return "hammer.fill"
		case .shell:
			return "fossil.shell.fill"
		case .fire:
			return "flame.fill"
		case .water:
			return "drop.fill"
		case .thunder:
			return "bolt.fill"
		case .ice:
			return "snowflake"
		case .dragon:
			return "atom"
		}
	}

	var label: LocalizedStringKey {
		LocalizedStringKey(rawValue)
	}

	var accessibilityLabel: LocalizedStringKey {
		switch self {
		case .slash:
			LocalizedStringKey("Slash Element")
		case .strike:
			LocalizedStringKey("Strike Element")
		case .shell:
			LocalizedStringKey("Shell Element")
		case .fire:
			LocalizedStringKey("Fire Element")
		case .water:
			LocalizedStringKey("Water Element")
		case .thunder:
			LocalizedStringKey("Thunder Element")
		case .ice:
			LocalizedStringKey("Ice Element")
		case .dragon:
			LocalizedStringKey("Dragon Element")
		}
	}
}
