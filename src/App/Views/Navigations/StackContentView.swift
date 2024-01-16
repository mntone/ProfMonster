#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
private struct _NavigationStackHost: View {
	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selectedGameID: String?

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: String?

	var body: some View {
		NavigationStack(path: path) {
			HomePage()
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(id):
						GamePage(id: id)
					case let .monster(id):
						MonsterPage(id: id)
					}
				}
		}
	}

	private var path: Binding<[MARoute]> {
		Binding {
			if let selectedGameID {
				if let selectedMonsterID {
					return [
						.game(id: selectedGameID),
						.monster(id: selectedMonsterID)
					]
				} else {
					return [
						.game(id: selectedGameID),
					]
				}
			}
			return []
		} set: { newValue in
			guard case let .game(gameID) = newValue.first else {
				selectedGameID = nil
				return
			}
			if selectedGameID != gameID {
				selectedGameID = gameID
			}

			guard newValue.count >= 2,
				  case let .monster(monsterID) = newValue[1] else {
				selectedMonsterID = nil
				return
			}

			if selectedMonsterID != monsterID {
				selectedMonsterID = monsterID
			}
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use _NavigationStackHost instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use _NavigationStackHost instead")
private struct _NavigationStackHostBackport: View {
	var body: some View {
		NavigationView {
			HomePageBackport()
		}
		.navigationViewStyle(.stack)
	}
}

@available(macOS, unavailable)
struct StackContentView: View {
	var body: some View {
		if #available(iOS 16.0, watchOS 9.0, *) {
			_NavigationStackHost()
		} else {
			_NavigationStackHostBackport()
		}
	}
}

#endif
