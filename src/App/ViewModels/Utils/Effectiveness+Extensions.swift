import enum MonsterAnalyzerCore.Effectiveness

extension Effectiveness {
	var label: String {
		switch self {
		case .mostEffective:
			String(localized: "+++", comment: "Effectiveness")
		case .effective:
			String(localized: "++", comment: "Effectiveness")
		case .hardlyEffective:
			String(localized: "+", comment: "Effectiveness")
		case .ineffective:
			String(localized: "0", comment: "Effectiveness")
		}
	}

	var accessibilityLabel: String {
		switch self {
		case .mostEffective:
			String(localized: "Most Effective", comment: "Effectiveness")
		case .effective:
			String(localized: "Effective", comment: "Effectiveness")
		case .hardlyEffective:
			String(localized: "Hardly Effective", comment: "Effectiveness")
		case .ineffective:
			String(localized: "Ineffective", comment: "Effectiveness")
		}
	}
}
