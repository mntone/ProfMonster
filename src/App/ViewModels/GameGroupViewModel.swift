import struct SwiftUI.LocalizedStringKey

@available(watchOS, unavailable)
enum GameGroupType: Hashable {
	case inGame
	case byName
	case favorite
	case type(id: String)
	
	var isType: Bool {
		if case .type = self {
			return true
		} else {
			return false
		}
	}
}

@available(watchOS, unavailable)
struct GameGroupViewModel: Identifiable {
	let gameID: String
	let type: GameGroupType
	let label: LocalizedStringKey
	let sortkey: String
	let items: [GameItemViewModel]

	init(gameID: String, type: GameGroupType, items: [GameItemViewModel]) {
		self.gameID = gameID
		self.type = type
		switch type {
		case .inGame, .byName:
			self.label = LocalizedStringKey("")
			self.sortkey = ""
		case .favorite:
			self.label = LocalizedStringKey("Favorite")
			self.sortkey = ""
		case let .type(id):
			let baseKey = id.replacingOccurrences(of: "_", with: " ").capitalized
			self.label = LocalizedStringKey(baseKey)
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

@available(watchOS, unavailable)
extension GameGroupViewModel: Equatable {
	static func == (lhs: GameGroupViewModel, rhs: GameGroupViewModel) -> Bool {
		lhs.type == rhs.type && lhs.gameID == rhs.gameID && lhs.items == rhs.items
	}
}

@available(watchOS, unavailable)
extension GameGroupViewModel: Comparable {
	static func <(lhs: GameGroupViewModel, rhs: GameGroupViewModel) -> Bool {
		lhs.sortkey < rhs.sortkey
	}
}
