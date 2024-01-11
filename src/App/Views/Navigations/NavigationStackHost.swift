import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct NavigationStackHost: View {
	@StateObject
	private var viewModel = HomeViewModel()

	let path: Binding<[MARoute]>

	var body: some View {
		NavigationStack(path: path) {
			HomeView(viewModel: viewModel)
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(id):
						GamePage(id: id) { item in
							MonsterListNavigatableItem(viewModel: item)
						}
					case let .monster(id):
						let viewModel = MonsterViewModel()
						let _ = viewModel.set(id: id)
						MonsterView(viewModel: viewModel)
					}
				}
		}
		.environment(\.settings, viewModel.app.settings)
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationStackHostBackport: View {
	@StateObject
	private var viewModel = HomeViewModel()

	let selectedGameID: Binding<HomeItemViewModel.ID?>
	let selectedMonsterID: Binding<GameItemViewModel.ID?>

	var body: some View {
		NavigationView {
			HomeViewBackport(viewModel: viewModel,
							 selectedGameID: selectedGameID,
							 selectedMonsterID: selectedMonsterID)
		}
		.navigationViewStyle(.stack)
		.environment(\.settings, viewModel.app.settings)
	}
}

#endif
