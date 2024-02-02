import MonsterAnalyzerCore

extension SwipeAction {
	var label: String {
		switch self {
		case .none:
			String(localized: "None")
		case .favorite:
			String(localized: "Favorite", comment: "SwipeAction")
		}
	}
}

// MARK: - Identifiable

extension SwipeAction: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
