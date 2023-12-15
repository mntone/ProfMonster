import SwiftUI

@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationPathSupport<Content: View>: View {
	@Environment(\.scenePhase)
	private var scenePhase

	@SceneStorage("path")
	private var pathData: Data?

	@ViewBuilder
	let content: (_ selectedGameID: Binding<String?>, _ selectedMonsterID: Binding<String?>) -> Content

	@State
	private var selectedGameID: String?

	@State
	private var selectedMonsterID: String?

	var body: some View {
		content($selectedGameID, $selectedMonsterID)
			.onAppear {
				loadPath()
			}
#if !os(macOS)
			.onDisappear {
				storePath()
			}
#endif
			.onChange(of: scenePhase) { newValue in
				switch newValue {
				case .background, .active:
					break
				case .inactive:
					if scenePhase == .active {
						storePath()
					}
					break
				@unknown default:
					fatalError()
				}
			}
	}

	private func loadPath() {
		let notCrashed = !MAApp.crashed
		MAApp.resetCrashed()
		guard notCrashed else {
			return
		}

		let path = RouteHelper.decode(pathData: pathData)
		if case let .game(gameID) = path.first {
			selectedGameID = gameID

			guard path.count >= 2,
				  case let .monster(gameID2, monsterID) = path[1] else {
				return
			}
			precondition(gameID == gameID2) // Assume X == Y for MARoute.game(X) and MARoute.monster(Y, _)
			selectedMonsterID = monsterID
		}
	}

	private func storePath() {
		let path: [MARoute]
		if let selectedGameID {
			if let selectedMonsterID {
				path = [
					.game(gameId: selectedGameID),
					.monster(gameId: selectedGameID, monsterId: selectedMonsterID),
				]
			} else {
				path = [.game(gameId: selectedGameID)]
			}
		} else {
			path = []
		}
		pathData = RouteHelper.encode(path: path)
	}
}
