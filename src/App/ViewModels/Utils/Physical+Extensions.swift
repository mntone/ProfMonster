import enum MonsterAnalyzerCore.Physical
import SwiftUI

extension Physical {
	var imageResource: ImageResource {
		switch self {
		case .slash:
			.slash
		case .impact:
			.impact
		case .shot:
			.shot
		}
	}

	enum LabelStyle {
		// English: Sls, Japanese: 斬
		case short
		// English: Slash, Japanese: 斬撃
		case medium
		// English: Slash Element, Japanese: 斬撃属性
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
			}
		case .medium:
			switch self {
			case .slash:
				String(localized: "Slash", comment: "Elem")
			case .impact:
				String(localized: "Impact", comment: "Elem")
			case .shot:
				String(localized: "Shot", comment: "Elem")
			}
		case .long:
			switch self {
			case .slash:
				String(localized: "Slash Element", comment: "Elem")
			case .impact:
				String(localized: "Impact Element", comment: "Elem")
			case .shot:
				String(localized: "Shot Element", comment: "Elem")
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
