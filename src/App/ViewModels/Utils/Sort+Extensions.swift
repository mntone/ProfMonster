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

	var fullLabel: String {
		switch self {
		case .inGame(false):
			String(localized: "In Game (Standard)", comment: "Sort")
		case .inGame(true):
			String(localized: "In Game (Reverse)", comment: "Sort")
		case .name(false):
			String(localized: "Name (Standard)", comment: "Sort")
		case .name(true):
			String(localized: "Name (Reverse)", comment: "Sort")
		case .type(false):
			String(localized: "Type (Standard)", comment: "Sort")
		case .type(true):
			String(localized: "Type (Reverse)", comment: "Sort")
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
