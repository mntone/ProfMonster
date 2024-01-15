import MonsterAnalyzerCore

extension WeaknessDisplayMode {
	var label: String {
		switch self {
		case .none:
			String(localized: "Off", comment: "DisplayMode")
		case .sign:
			String(localized: "Sign", comment: "DisplayMode")
		case .number:
			String(localized: "Number (1st decimal place)", comment: "DisplayMode")
		case .number2:
			String(localized: "Number (2nd decimal place)", comment: "DisplayMode")
		}
	}
}

// MARK: - Identifiable

extension WeaknessDisplayMode: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
