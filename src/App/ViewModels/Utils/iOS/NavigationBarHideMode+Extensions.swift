import enum MonsterAnalyzerCore.NavigationBarHideMode

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension NavigationBarHideMode {
	var label: String {
		switch self {
		case .nothing:
			String(localized: "Always Show", comment: "NavigationBarHideMode")
		case .editingLandscape:
			String(localized: "Hide When Editing in Landscape Mode", comment: "NavigationBarHideMode")
		case .editing:
			String(localized: "Hide When Editing", comment: "NavigationBarHideMode")
		}
	}
}

// MARK: - Identifiable

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension NavigationBarHideMode: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
