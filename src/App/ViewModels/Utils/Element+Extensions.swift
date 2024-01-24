import enum MonsterAnalyzerCore.Element
import SwiftUI

extension Element {
	var color: Color {
		switch self {
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

	var image: Image {
		switch self {
		case .fire:
			return Image(systemName: "flame.fill")
		case .water:
			return Image(.water)
		case .thunder:
			return Image(.thunder)
		case .ice:
			return Image(systemName: "snowflake")
		case .dragon:
			return Image(.dragon)
		}
	}

	enum LabelStyle {
		// English: Fir (watchOS) / Fire (Other), Japanese: 火
		case short
		// English: Fire, Japanese: 火属性
		case medium
		// English: Fire Element, Japanese: 火属性
		case long
	}

	func label(_ style: LabelStyle) -> String {
		switch style {
		case .short:
			switch self {
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

	var prefix: String {
		switch self {
		case .fire:
			"f"
		case .water:
			"w"
		case .thunder:
			"t"
		case .ice:
			"i"
		case .dragon:
			"d"
		}
	}

	var sortkey: String {
		switch self {
		case .fire:
			"5"
		case .water:
			"6"
		case .thunder:
			"7"
		case .ice:
			"8"
		case .dragon:
			"9"
		}
	}
}
