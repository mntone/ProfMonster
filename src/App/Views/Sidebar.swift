import MonsterAnalyzerCore
import SwiftUI

struct Sidebar: View {
	@Environment(\.presentSettingsSheetAction)
	private var presentSettingsSheetAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	let selection: Binding<GameViewModel.ID?>

	var body: some View {
		List(viewModel.state.data ?? [], id: \.id, selection: selection) { item in
			Text(verbatim: item.name)
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier {
			presentSettingsSheetAction()
		})
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
struct SidebarBackport: View {
	@Environment(\.presentSettingsSheetAction)
	private var presentSettingsSheetAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	let selection: Binding<GameViewModel.ID?>

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			SelectableListRowBackport(tag: item.id, selection: selection) {
				Text(verbatim: item.name)
			}
		}
		.modifier(StatusOverlayModifier(state: viewModel.state))
		.modifier(SharedGameListModifier {
			presentSettingsSheetAction()
		})
	}
}

#endif

#Preview {
	Sidebar(viewModel: HomeViewModel(),
			selection: .constant(nil))
}
