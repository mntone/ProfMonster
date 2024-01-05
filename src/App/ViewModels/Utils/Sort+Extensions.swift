import enum MonsterAnalyzerCore.Sort

extension Sort {
	var label: String {
		switch self {
		case .inGame:
			String(localized: "In Game", comment: "Sort")
		case .name:
			String(localized: "Name", comment: "Sort")
		case .type:
			String(localized: "Type", comment: "Sort")
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
