import MonsterAnalyzerCore
import SwiftUI

extension WeaknessDisplayMode {
	var label: String {
		switch self {
		case .none:
			String(localized: "Off", comment: "DisplayMode")
		case .sign:
			String(localized: "Sign", comment: "DisplayMode")
		case let .number(fractionLength):
			String(localized: "Number (\(fractionLength) decimal places)",
				   comment: "DisplayMode")
		}
	}
}
