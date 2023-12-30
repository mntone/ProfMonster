import MonsterAnalyzerCore
import SwiftUI

extension WeaknessDisplayMode {
	var label: LocalizedStringKey {
		switch self {
		case .none:
			LocalizedStringKey("Off")
		case .sign:
			LocalizedStringKey("Sign")
		case let .number(fractionLength):
			LocalizedStringKey("Number (\(fractionLength) decimal places)")
		}
	}
}
