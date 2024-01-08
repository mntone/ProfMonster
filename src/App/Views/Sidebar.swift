import MonsterAnalyzerCore
import SwiftUI

@available(watchOS, unavailable)
struct Sidebar: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selection: HomeItemViewModel.ID?

	var body: some View {
		List(viewModel.items, id: \.id, selection: $selection) { item in
			Text(item.name)
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.onAppear {
			if selection == nil {
				selection = viewModel.items.first?.id
			}
		}
		.onChangeBackport(of: viewModel.items) { _, newValue in
			selection = newValue.first?.id
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SidebarBackport: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selection: HomeItemViewModel.ID?

	var body: some View {
		List(viewModel.items) { item in
			RoundedRectangleSelectableListRowBackport(tag: item.id, selection: $selection) {
				Text(item.name)
			}
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.onAppear {
			if selection == nil {
				selection = viewModel.items.first?.id
			}
		}
		.onChangeBackport(of: viewModel.items) { _, newValue in
			selection = newValue.first?.id
		}
	}
}

#endif

#Preview {
	Sidebar(viewModel: HomeViewModel(),
			selection: .constant(nil))
}
