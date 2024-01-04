import enum MonsterAnalyzerCore.Sort

extension Sort {
	var label: String {
		switch self {
		case .inGame:
			String(localized: "In Game", comment: "Sort/In Game")
		case .name:
			String(localized: "Name", comment: "Sort/Name")
		case .type:
			String(localized: "Type", comment: "Sort/Type")
		}
	}
}

// MARK: - Identifiable

extension Sort: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
