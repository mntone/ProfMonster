import MonsterAnalyzerCore
import SwiftUI

@available(watchOS, unavailable)
struct Sidebar: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	let selection: Binding<HomeItemViewModel.ID?>

	var body: some View {
		List(viewModel.state.data ?? [], id: \.id, selection: selection) { item in
			Text(item.name)
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SidebarBackport: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

	let selection: Binding<HomeItemViewModel.ID?>

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			SelectableListRowBackport(tag: item.id, selection: selection) {
				Text(item.name)
			}
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

#endif

#Preview {
	Sidebar(viewModel: HomeViewModel(),
			selection: .constant(nil))
}
