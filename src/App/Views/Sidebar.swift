import MonsterAnalyzerCore
import SwiftUI

struct Sidebar: View {
#if !os(macOS)
	@Environment(\.settingsAction)
	private var settingsAction
#endif

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selectedGameID: String?

	var body: some View {
		List(viewModel.items, id: \.id, selection: $selectedGameID) { item in
			Text(verbatim: item.name)
		}
#if !os(macOS)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Settings", systemImage: "gearshape.fill") {
					settingsAction?.present()
				}
				.keyboardShortcut(",", modifiers: [.command])
			}
		}
		.navigationTitle("Prof. Monster")
#endif
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
		List(viewModel.items, id: \.id) { item in
			SelectableListRowBackport(tag: item.id, selection: $selectedGameID) {
				Text(verbatim: item.name)
			}
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("Settings", systemImage: "gearshape.fill") {
					settingsAction?.present()
				}
				.keyboardShortcut(",", modifiers: [.command])
			}
		}
		.navigationTitle("Prof. Monster")
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
