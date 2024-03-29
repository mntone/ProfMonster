import MonsterAnalyzerCore

extension ElementWeaknessDisplayMode {
	var label: String {
		switch self {
		case .none:
			String(localized: "Off", comment: "DisplayMode")
		case .sign:
			String(localized: "Sign", comment: "DisplayMode")
		case .number:
			String(localized: "Number (1st Decimal Place)", comment: "DisplayMode")
		case .number2:
			String(localized: "Number (2nd Decimal Place)", comment: "DisplayMode")
		}
	}

	var fractionLength: Int {
		switch self {
		case .number:
			1
		case .number2:
			2
		default:
			0
		}
	}
}

// MARK: - Identifiable

extension ElementWeaknessDisplayMode: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
