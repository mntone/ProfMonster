import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct NavigationStackHost: View {
	let viewModel: HomeViewModel
	let path: Binding<[MARoute]>

	var body: some View {
		NavigationStack(path: path) {
			HomeView(viewModel: viewModel)
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(gameId):
						let viewModel = GameViewModel()
						let _ = viewModel.set(id: gameId)
						GamePage(viewModel: viewModel) { item in
							MonsterListNavigatableItem(viewModel: item)
						}
					case let .monster(gameId, monsterId):
						let viewModel = MonsterViewModel(id: monsterId, for: gameId)!
						MonsterView(viewModel: viewModel)
					}
				}
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationStackHostBackport: View {
	let viewModel: HomeViewModel
	let selectedGameID: Binding<HomeItemViewModel.ID?>
	let selectedMonsterID: Binding<MonsterViewModel.ID?>

	var body: some View {
		NavigationView {
			HomeViewBackport(viewModel: viewModel,
							 selectedGameID: selectedGameID,
							 selectedMonsterID: selectedMonsterID)
		}
		.navigationViewStyle(.stack)
	}
}

#endif
