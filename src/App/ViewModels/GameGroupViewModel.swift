import enum MonsterAnalyzerCore.Attack

enum GameGroupType: Hashable {
	case favorite
	case none
	case type(id: String)
	case weakness(element: Attack?)

	var isFavorite: Bool {
		if case .favorite = self {
			return true
		} else {
			return false
		}
	}

	var isValidType: Bool {
		switch self {
		case .type, .weakness:
			return true
		default:
			return false
		}
	}

	var isType: Bool {
		if case .type = self {
			return true
		} else {
			return false
		}
	}
}

struct GameGroupViewModel: Identifiable {
	let gameID: String
	let type: GameGroupType
	let label: String
	let sortkey: String
	let items: [IdentifyHolder<GameItemViewModel>]

	init(gameID: String, type: GameGroupType, items: [IdentifyHolder<GameItemViewModel>]) {
		self.gameID = gameID
		self.type = type
		switch type {
		case .favorite:
			self.label = String(localized: "Favorites")
			self.sortkey = "0"
		case .none:
			self.label = String(localized: "All Monsters")
			self.sortkey = "1"
		case let .type(id):
			let baseKey = id.replacingOccurrences(of: "_", with: " ").capitalized
			self.label = String(localized: String.LocalizationValue(baseKey))
			self.sortkey = String(localized: String.LocalizationValue(baseKey + "_SORTKEY"))
		case .weakness(.none):
			self.label = String(localized: "Ineffective")
			self.sortkey = "1"
		case let .weakness(.some(element)):
			self.label = element.label(.medium)
			self.sortkey = element.sortkey
		}
		self.items = items
	}

	var id: GameGroupType {
		@inline(__always)
		get {
			type
		}
	}
}

extension GameGroupViewModel: Equatable {
	static func == (lhs: GameGroupViewModel, rhs: GameGroupViewModel) -> Bool {
		lhs.type == rhs.type && lhs.gameID == rhs.gameID && lhs.items == rhs.items
	}
}

extension GameGroupViewModel: Comparable {
	static func <(lhs: GameGroupViewModel, rhs: GameGroupViewModel) -> Bool {
		lhs.sortkey < rhs.sortkey
	}
}
