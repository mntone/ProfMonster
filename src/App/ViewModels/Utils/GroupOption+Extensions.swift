import enum MonsterAnalyzerCore.GroupOption

extension GroupOption {
	var label: String {
		switch self {
		case .none:
			String(localized: "None", comment: "GroupOption")
		case .type:
			String(localized: "Type", comment: "GroupOption")
		case .weakness:
			String(localized: "Weakness", comment: "GroupOption")
		}
	}
}

// MARK: - Identifiable

extension GroupOption: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
