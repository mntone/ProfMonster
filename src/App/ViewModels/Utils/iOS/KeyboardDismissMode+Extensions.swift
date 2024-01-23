import enum MonsterAnalyzerCore.KeyboardDismissMode

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardDismissMode {
	var label: String {
		switch self {
		case .button:
			String(localized: "Button", comment: "KeyboardDismissMode")
		case .scroll:
			String(localized: "Scroll", comment: "KeyboardDismissMode")
		case .swipe:
			String(localized: "Swipe", comment: "KeyboardDismissMode")
		}
	}
}

// MARK: - Identifiable

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardDismissMode: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
