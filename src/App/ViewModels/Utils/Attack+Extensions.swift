import enum MonsterAnalyzerCore.Attack
import SwiftUI

extension Attack {
	var color: Color {
		switch self {
		case .slash, .impact, .shot:
			return .secondary
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
		case .slash:
			return Image(.slash)
		case .impact:
			return Image(.impact)
		case .shot:
			return Image(.shot)
		case .fire:
			return Image(systemName: "flame.fill")
		case .water:
			return Image(.water)
		case .thunder:
			return Image(.thunder)
		case .ice:
			return Image(.ice)
		case .dragon:
			return Image(.dragon)
		}
	}

	enum LabelStyle {
		// English: Fir, Japanese: 火
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
			case .slash:
				String(localized: "Sls", comment: "Elem")
			case .impact:
				String(localized: "Imp", comment: "Elem")
			case .shot:
				String(localized: "Sht", comment: "Elem")
			case .fire:
				String(localized: "Fir", comment: "Elem")
			case .water:
				String(localized: "Wtr", comment: "Elem")
			case .thunder:
				String(localized: "Thn", comment: "Elem")
			case .ice:
				String(localized: "Ice (Short)", comment: "Elem")
			case .dragon:
				String(localized: "Drg", comment: "Elem")
			}
		case .medium:
			switch self {
			case .slash:
				String(localized: "Slash", comment: "Elem")
			case .impact:
				String(localized: "Impact", comment: "Elem")
			case .shot:
				String(localized: "Shot", comment: "Elem")
			case .fire:
				String(localized: "Fire", comment: "Elem")
			case .water:
				String(localized: "Water", comment: "Elem")
			case .thunder:
				String(localized: "Thunder", comment: "Elem")
			case .ice:
				String(localized: "Ice", comment: "Elem")
			case .dragon:
				String(localized: "Dragon", comment: "Elem")
			}
		case .long:
			switch self {
			case .slash:
				String(localized: "Slash Element", comment: "Elem")
			case .impact:
				String(localized: "Impact Element", comment: "Elem")
			case .shot:
				String(localized: "Shot Element", comment: "Elem")
			case .fire:
				String(localized: "Fire Element", comment: "Elem")
			case .water:
				String(localized: "Water Element", comment: "Elem")
			case .thunder:
				String(localized: "Thunder Element", comment: "Elem")
			case .ice:
				String(localized: "Ice Element", comment: "Elem")
			case .dragon:
				String(localized: "Dragon Element", comment: "Elem")
			}
		}
	}

	var prefix: String {
		switch self {
		case .slash:
			"s"
		case .impact:
			"m"
		case .shot:
			"p"
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
		case .slash:
			"2"
		case .impact:
			"3"
		case .shot:
			"4"
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
