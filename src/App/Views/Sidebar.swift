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

#Preview {
	Sidebar(viewModel: HomeViewModel(),
			selectedGameID: .constant(nil))
}
