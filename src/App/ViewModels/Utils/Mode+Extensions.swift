import enum MonsterAnalyzerCore.Mode

extension Mode {
	enum LabelStyle {
		case short
		case medium
		case long
	}

	var key: String {
		switch self {
		case .lowAndHigh:
			"d"
		case .high:
			"h"
		case .master:
			"m"
		case .rankG:
			"g"
		case let .other(name):
			name
		}
	}

	func label(_ style: LabelStyle) -> String {
		switch style {
		case .short:
			switch self {
			case .lowAndHigh:
				String(localized: "LR & HR", comment: "Mode")
			case .high:
				String(localized: "HR", comment: "Mode")
			case .master:
				String(localized: "MR", comment: "Mode")
			case .rankG:
				String(localized: "GR", comment: "Mode")
			case let .other(name):
				name.capitalized
			}
		case .medium:
			switch self {
			case .lowAndHigh:
				String(localized: "Low & High", comment: "Mode")
			case .high:
				String(localized: "High", comment: "Mode")
			case .master:
				String(localized: "Master", comment: "Mode")
			case .rankG:
				String(localized: "G Rank", comment: "Mode")
			case let .other(name):
				name.capitalized
			}
		case .long:
			switch self {
			case .lowAndHigh:
				String(localized: "Low & High Rank", comment: "Mode")
			case .high:
				String(localized: "High Rank", comment: "Mode")
			case .master:
				String(localized: "Master Rank", comment: "Mode")
			case .rankG:
				String(localized: "G Rank", comment: "Mode")
			case let .other(name):
				name.capitalized
			}
		}
	}
}

// MARK: - Identifiable

extension Mode: Identifiable {
	public var id: String {
		@inline(__always)
		get {
			rawValue
		}
	}
}
