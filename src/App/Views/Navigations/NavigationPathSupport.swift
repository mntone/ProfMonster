import SwiftUI

@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationPathSupport<Content: View>: View {
	@Environment(\.scenePhase)
	private var scenePhase

	@Binding
	var pathString: String?

	@ViewBuilder
	let content: (_ selectedGameID: Binding<String?>, _ selectedMonsterID: Binding<String?>) -> Content

	@State
	private var selectedGameID: String?

	@State
	private var selectedMonsterID: String?

	var body: some View {
		content($selectedGameID, $selectedMonsterID)
			.task {
				await loadPath()
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

	private func loadPath() async {
		let path = await RouteHelper.load(from: pathString)
		if case let .game(rootGameID) = path.first {
			selectedGameID = rootGameID

			guard path.count >= 2,
				  case let .monster(gameID, monsterID) = path[1] else {
				return
			}
			precondition(rootGameID == gameID) // Assume X == Y for .game(X) and .monster(Y, _)
			selectedMonsterID = monsterID
		}
	}

	private func storePath() {
		let path: [MARoute]
		if let selectedGameID {
			if let selectedMonsterID {
				path = [
					.game(gameID: selectedGameID),
					.monster(gameID: selectedGameID, monsterID: selectedMonsterID),
				]
			} else {
				path = [.game(gameID: selectedGameID)]
			}
		} else {
			path = []
		}
		pathString = RouteHelper.encode(path: path)
	}
}
