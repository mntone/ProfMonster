import MonsterAnalyzerCore
import SwiftUI

struct Sidebar: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selectedGameID: String?

	var body: some View {
		List(viewModel.state.data ?? [], id: \.id, selection: $selectedGameID) { item in
			Text(verbatim: item.name)
		}
		.modifier(SharedGameListModifier(isLoading: viewModel.state.isLoading) {
			settingsAction?.present()
		})
		.task {
			viewModel.fetchData()
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use Sidebar instead")
struct SidebarBackport: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selectedGameID: String?

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			SelectableListRowBackport(tag: item.id, selection: $selectedGameID) {
				Text(verbatim: item.name)
			}
		}
		.modifier(SharedGameListModifier(isLoading: viewModel.state.isLoading) {
			settingsAction?.present()
		})
		.task {
			viewModel.fetchData()
		}
	}
}

#endif

#Preview {
	Sidebar(viewModel: HomeViewModel(),
			selectedGameID: .constant(nil))
}
