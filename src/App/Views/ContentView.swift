import SwiftUI

struct ContentView: View {
#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
#endif

	@SceneStorage("_p")
	private var pathString: String?

#if !os(macOS)
	@State
	private var isSettingsPresented: Bool = false
#endif

	var body: some View {
		Group {
#if os(macOS)
			NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
				if #available(macOS 13.0, *) {
					NavigationSplitViewHost(selectedGameID: gameID,
											selectedMonsterID: monsterID)
				} else {
					NavigationSplitViewHostBackport(selectedGameID: gameID,
													selectedMonsterID: monsterID)
				}
			}
#elseif os(watchOS)
			if #available(watchOS 9.0, *) {
				NavigationPathHost(pathString: $pathString) { path in
					NavigationStackHost(path: path)
				}
			} else {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					NavigationStackHostBackport(selectedGameID: gameID,
												selectedMonsterID: monsterID)
				}
			}
#else
			if UIDevice.current.userInterfaceIdiom == .pad,
			   horizontalSizeClass == .regular {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					if #available(iOS 16.0, *) {
						NavigationSplitViewHost(selectedGameID: gameID,
												selectedMonsterID: monsterID)
					} else {
						NavigationSplitViewHostBackport(selectedGameID: gameID,
														selectedMonsterID: monsterID)
					}
				}
			} else if #available(iOS 16.0, *) {
				NavigationPathHost(pathString: $pathString) { path in
					NavigationStackHost(path: path)
				}
			} else {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					NavigationStackHostBackport(selectedGameID: gameID,
												selectedMonsterID: monsterID)
				}
			}
#endif
		}
#if !os(macOS)
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainer()
		}
		.setPresentSettingsSheetAction(isPresented: $isSettingsPresented)
#endif
	}
}
