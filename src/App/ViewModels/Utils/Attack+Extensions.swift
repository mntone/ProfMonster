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
				String(localized: "Slash", comment: "Element/Slash (Short)")
			case .strike:
				String(localized: "Strike", comment: "Element/Strike (Short)")
			case .shell:
				String(localized: "Shell", comment: "Element/Shell (Short)")
			case .fire:
				String(localized: "Fire", comment: "Element/Fire (Short)")
			case .water:
				String(localized: "Water", comment: "Element/Water (Short)")
			case .thunder:
				String(localized: "Thunder", comment: "Element/Thunder (Short)")
			case .ice:
				String(localized: "Ice", comment: "Element/Ice (Short)")
			case .dragon:
				String(localized: "Dragon", comment: "Element/Dragon (Short)")
			}
		case .medium:
			switch self {
			case .slash:
				String(localized: "Slash_MEDIUM", comment: "Element/Slash (Medium)")
			case .strike:
				String(localized: "Strike_MEDIUM", comment: "Element/Strike (Medium)")
			case .shell:
				String(localized: "Shell_MEDIUM", comment: "Element/Shell (Medium)")
			case .fire:
				String(localized: "Fire_MEDIUM", comment: "Element/Fire (Medium)")
			case .water:
				String(localized: "Water_MEDIUM", comment: "Element/Water (Medium)")
			case .thunder:
				String(localized: "Thunder_MEDIUM", comment: "Element/Thunder (Medium)")
			case .ice:
				String(localized: "Ice_MEDIUM", comment: "Element/Ice (Medium)")
			case .dragon:
				String(localized: "Dragon_MEDIUM", comment: "Element/Dragon (Medium)")
			}
		case .long:
			switch self {
			case .slash:
				String(localized: "Slash Element", comment: "Element/Slash (Long)")
			case .strike:
				String(localized: "Strike Element", comment: "Element/Strike (Long)")
			case .shell:
				String(localized: "Shell Element", comment: "Element/Shell (Long)")
			case .fire:
				String(localized: "Fire Element", comment: "Element/Fire (Long)")
			case .water:
				String(localized: "Water Element", comment: "Element/Water (Long)")
			case .thunder:
				String(localized: "Thunder Element", comment: "Element/Thunder (Long)")
			case .ice:
				String(localized: "Ice Element", comment: "Element/Ice (Long)")
			case .dragon:
				String(localized: "Dragon Element", comment: "Element/Dragon (Long)")
			}
		}
	}
}
