import SwiftUI

final class CoordinatorViewModel: ObservableObject {
	typealias GameIDType = String
	typealias MonsterIDType = String

	@Published
	var selectedGameID: GameIDType?

	@Published
	var selectedMonsterID: MonsterIDType?

	var path: Binding<[MARoute]> {
		Binding { [weak self] in
			guard let self else { return [] }

			if let gameID = self.selectedGameID {
				if let monsterID = self.selectedMonsterID {
					return [
						.game(id: gameID),
						.monster(id: monsterID)
					]
				} else {
					return [
						.game(id: gameID),
					]
				}
			}
			return []
		} set: { [weak self] newValue in
			guard let self else { return }

			var mappingSelection = Transaction()
			mappingSelection.disablesAnimations = true
			withTransaction(mappingSelection) {
				guard case let .game(gameID) = newValue.first else {
					return
				}
				if self.selectedGameID != gameID {
					self.selectedGameID = gameID
				}

				guard newValue.count >= 2,
					  case let .monster(monsterID) = newValue[1] else {
					self.selectedMonsterID = nil
					return
				}

				if self.selectedMonsterID != monsterID {
					self.selectedMonsterID = monsterID
				}
			}
		}
	}

	init(gameID: GameIDType? = nil,
		 monsterID: MonsterIDType? = nil) {
		self.selectedGameID = gameID
		self.selectedMonsterID = monsterID
	}
}
