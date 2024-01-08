
enum GameGroupType: Hashable {
	case inGame(reversed: Bool)
	case byName(reversed: Bool)
	case favorite
	case type(id: String, reversed: Bool)

	var isFavorite: Bool {
		if case .favorite = self {
			return true
		} else {
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
		case .inGame, .byName:
			self.label = String(localized: "All Monsters")
			self.sortkey = "1"
		case .favorite:
			self.label = String(localized: "Favorites")
			self.sortkey = "0"
		case let .type(id, _):
			let baseKey = id.replacingOccurrences(of: "_", with: " ").capitalized
			self.label = String(localized: String.LocalizationValue(baseKey))
			self.sortkey = String(localized: String.LocalizationValue(baseKey + "_SORTKEY"))
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
