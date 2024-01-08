import SwiftUI

@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationPathSupport<Content: View>: View {
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
#if os(iOS)
			.onDisappear(perform: storePath)
#endif
			.onReceive(NotificationCenter.default.publisher(for: .platformWillResignActiveNotification), perform: storePath(_:))
	}

	private func loadPath() async {
		let path = await RouteHelper.load(from: pathString)

		if case let .game(rootGameID) = path.first {
			var storingSelection = Transaction()
			storingSelection.disablesAnimations = true

			withTransaction(storingSelection) {
				selectedGameID = rootGameID

				guard path.count >= 2,
					  case let .monster(monsterID) = path[1] else {
					return
				}
				selectedMonsterID = monsterID
			}
		}
	}

	private func storePath(_: Notification) {
		storePath()
	}

	private func storePath() {
		let path: [MARoute]
		if let selectedGameID {
			if let selectedMonsterID {
				path = [
					.game(id: selectedGameID),
					.monster(id: selectedMonsterID),
				]
			} else {
				path = [.game(id: selectedGameID)]
			}
		} else {
			path = []
		}
		pathString = RouteHelper.encode(path: path)
	}
}
