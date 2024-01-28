import enum MonsterAnalyzerCore.Physical
import SwiftUI

extension Physical {
	var image: Image {
		switch self {
		case .slash:
			return Image(systemName: "scissors")
		case .impact:
			return Image(.impact)
		case .shot:
			return Image(.shot)
		}
	}

	enum LabelStyle {
		// English: Sls (watchOS) / Slash (the others), Japanese: 斬 (watchOS) / 斬撃 (the others)
		case short
		// English: Slash, Japanese: 斬撃属性
		case medium
		// English: Slash Element, Japanese: 斬撃属性
		case long
	}

	func label(_ style: LabelStyle) -> String {
		switch style {
		case .short:
			switch self {
			case .slash:
				String(localized: "Slash", comment: "Elem/Short")
			case .impact:
				String(localized: "Strike", comment: "Elem/Short")
			case .shot:
				String(localized: "Shell", comment: "Elem/Short")
			}
		case .medium:
			switch self {
			case .slash:
				String(localized: "Slash_MEDIUM", comment: "Elem/Medium")
			case .impact:
				String(localized: "Strike_MEDIUM", comment: "Elem/Medium")
			case .shot:
				String(localized: "Shell_MEDIUM", comment: "Elem/Medium")
			}
		case .long:
			switch self {
			case .slash:
				String(localized: "Slash Element", comment: "Elem/Long")
			case .impact:
				String(localized: "Strike Element", comment: "Elem/Long")
			case .shot:
				String(localized: "Shell Element", comment: "Elem/Long")
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
		}
	}
}
