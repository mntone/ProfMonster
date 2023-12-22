import SwiftUI

struct ContentView: View {
	let viewModel: HomeViewModel

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
					NavigationSplitViewHost(viewModel: viewModel,
											selectedGameID: gameID,
											selectedMonsterID: monsterID)
				} else {
					NavigationSplitViewHostBackport(viewModel: viewModel,
													selectedGameID: gameID,
													selectedMonsterID: monsterID)
				}
			}
#elseif os(watchOS)
			if #available(watchOS 9.0, *) {
				NavigationPathHost(pathString: $pathString) { path in
					NavigationStackHost(viewModel: viewModel, path: path)
				}
			} else {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					NavigationStackHostBackport(viewModel: viewModel,
												selectedGameID: gameID,
												selectedMonsterID: monsterID)
				}
			}
#else
			if UIDevice.current.userInterfaceIdiom == .pad,
			   horizontalSizeClass == .regular {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					if #available(iOS 16.0, *) {
						NavigationSplitViewHost(viewModel: viewModel,
												selectedGameID: gameID,
												selectedMonsterID: monsterID)
					} else {
						NavigationSplitViewHostBackport(viewModel: viewModel,
														selectedGameID: gameID,
														selectedMonsterID: monsterID)
					}
				}
			} else if #available(iOS 16.0, *) {
				NavigationPathHost(pathString: $pathString) { path in
					NavigationStackHost(viewModel: viewModel, path: path)
				}
			} else {
				NavigationPathSupport(pathString: $pathString) { gameID, monsterID in
					NavigationStackHostBackport(viewModel: viewModel,
												selectedGameID: gameID,
												selectedMonsterID: monsterID)
				}
			}
#endif
		}
#if !os(macOS)
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainer(viewModel: SettingsViewModel(rootViewModel: viewModel))
		}
		.setPresentSettingsSheetAction(isPresented: $isSettingsPresented)
#endif
	}
}
