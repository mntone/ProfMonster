import enum MonsterAnalyzerCore.Sort

extension Sort {
	var label: String {
		switch self {
		case .inGame:
			String(localized: "In Game", comment: "Sort")
		case .name:
			String(localized: "Name", comment: "Sort")
		}
	}

	var fullLabel: String {
		switch self {
		case .inGame(false):
			String(localized: "In Game (Standard)", comment: "Sort")
		case .inGame(true):
			String(localized: "In Game (Reverse)", comment: "Sort")
		case .name(false, _):
			String(localized: "Name (A to Z)", comment: "Sort")
		case .name(true, _):
			String(localized: "Name (Z to A)", comment: "Sort")
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
