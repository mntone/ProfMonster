import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct Sidebar: View {
	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selection: String?

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items, id: \.id, selection: $selection) { item in
			Text(item.name)
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.task {
			if selection == nil {
				selection = viewModel.items.first?.id
			}
		}
		.onChangeBackport(of: viewModel.items) { _, newValue in
			if selection != nil {
				if !newValue.contains(where: { item in item.id == selection }) {
					selection = newValue.first?.id
				}
			} else {
				selection = newValue.first?.id
			}
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SidebarBackport: View {
	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selection: String?

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items) { item in
			RoundedRectangleSelectableListRowBackport(tag: item.id, selection: $selection) {
				Text(item.name)
			}
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))

		// Select the first item when new scene.
		.task {
			if selection == nil {
				selection = viewModel.items.first?.id
			}
		}
		.onChange(of: viewModel.items) { newValue in
			if selection != nil {
				if !newValue.contains(where: { item in item.id == selection }) {
					selection = newValue.first?.id
				}
			} else {
				selection = newValue.first?.id
			}
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
}

#if os(iOS)

#Preview("Backport") {
	SidebarBackport()
}

#endif
