import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct HomeView: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	var body: some View {
		List(viewModel.items) { item in
			NavigationLink(item.name, value: MARoute.game(id: item.id))
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use HomeView instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use HomeView instead")
struct HomeViewBackport: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	let selectedGameID: Binding<HomeItemViewModel.ID?>
	let selectedMonsterID: Binding<MonsterViewModel.ID?>

	var body: some View {
		List(viewModel.items) { item in
			NavigationLink(item.name, tag: item.id, selection: selectedGameID) {
				GamePage(id: item.id) { item in
					MonsterListNavigatableItemBackport(viewModel: item,
													   selection: selectedMonsterID)
				}
			}
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

@available(iOS 16.0, watchOS 9.0, *)
#Preview("Default") {
	HomeView(viewModel: HomeViewModel())
}

#Preview("Backport") {
	HomeViewBackport(viewModel: HomeViewModel(),
					 selectedGameID: .constant(nil),
					 selectedMonsterID: .constant(nil))
}

#endif
