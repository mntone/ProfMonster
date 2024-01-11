import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct Sidebar: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items, id: \.id, selection: $coord.selectedGameID) { item in
			Text(item.name)
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.onAppear {
			if coord.selectedGameID == nil {
				coord.selectedGameID = viewModel.items.first?.id
			}
		}
		.onChangeBackport(of: viewModel.items) { _, newValue in
			coord.selectedGameID = newValue.first?.id
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SidebarBackport: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items) { item in
			RoundedRectangleSelectableListRowBackport(tag: item.id, selection: $coord.selectedGameID) {
				Text(item.name)
			}
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.onAppear {
			if coord.selectedGameID == nil {
				coord.selectedGameID = viewModel.items.first?.id
			}
		}
		.onChangeBackport(of: viewModel.items) { _, newValue in
			coord.selectedGameID = newValue.first?.id
		}
	}
}

#endif

@available(iOS 16.0, *)
#Preview("Default") {
	Sidebar()
#if os(macOS)
		.frame(minWidth: 120, idealWidth: 150, maxWidth: 180)
#endif
		.environmentObject(CoordinatorViewModel())
}

#if os(iOS)

#Preview("Backport") {
	SidebarBackport()
		.environmentObject(CoordinatorViewModel())
}

#endif
