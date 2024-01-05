import MonsterAnalyzerCore
import SwiftUI

enum AttackLabelStyle {
	// English: Fir (watchOS) / Fire (Other), Japanese: 火
	case short
	// English: Fire, Japanese: 火属性
	case medium
	// English: Fire Element, Japanese: 火属性
	case long
}

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

	func label(_ style: AttackLabelStyle) -> String {
		switch style {
		case .short:
			switch self {
			case .slash:
				String(localized: "Slash", comment: "Elem/Short")
			case .strike:
				String(localized: "Strike", comment: "Elem/Short")
			case .shell:
				String(localized: "Shell", comment: "Elem/Short")
			case .fire:
				String(localized: "Fire", comment: "Elem/Short")
			case .water:
				String(localized: "Water", comment: "Elem/Short")
			case .thunder:
				String(localized: "Thunder", comment: "Elem/Short")
			case .ice:
				String(localized: "Ice", comment: "Elem/Short")
			case .dragon:
				String(localized: "Dragon", comment: "Elem/Short")
			}
		case .medium:
			switch self {
			case .slash:
				String(localized: "Slash_MEDIUM", comment: "Elem/Medium")
			case .strike:
				String(localized: "Strike_MEDIUM", comment: "Elem/Medium")
			case .shell:
				String(localized: "Shell_MEDIUM", comment: "Elem/Medium")
			case .fire:
				String(localized: "Fire_MEDIUM", comment: "Elem/Medium")
			case .water:
				String(localized: "Water_MEDIUM", comment: "Elem/Medium")
			case .thunder:
				String(localized: "Thunder_MEDIUM", comment: "Elem/Medium")
			case .ice:
				String(localized: "Ice_MEDIUM", comment: "Elem/Medium")
			case .dragon:
				String(localized: "Dragon_MEDIUM", comment: "Elem/Medium")
			}
		case .long:
			switch self {
			case .slash:
				String(localized: "Slash Element", comment: "Elem/Long")
			case .strike:
				String(localized: "Strike Element", comment: "Elem/Long")
			case .shell:
				String(localized: "Shell Element", comment: "Elem/Long")
			case .fire:
				String(localized: "Fire Element", comment: "Elem/Long")
			case .water:
				String(localized: "Water Element", comment: "Elem/Long")
			case .thunder:
				String(localized: "Thunder Element", comment: "Elem/Long")
			case .ice:
				String(localized: "Ice Element", comment: "Elem/Long")
			case .dragon:
				String(localized: "Dragon Element", comment: "Elem/Long")
			}
		}
	}
}
