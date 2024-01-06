import SwiftUI

struct SharedGameListModifier: ViewModifier {
	let viewModel: HomeViewModel

	@Environment(\.presentSettingsSheetAction)
	private var presentSettingsSheetAction

	func body(content: Content) -> some View {
		content
			.onChangeBackport(of: viewModel.state.isReady, initial: true) { _, newValue in
				if newValue {
					viewModel.fetchData()
				}
			}
#if !os(macOS)
			.toolbarItemBackport(alignment: .leading) {
				Button("Settings",
					   systemImage: "gearshape.fill",
					   action: presentSettingsSheetAction.callAsFunction)
#if !os(watchOS)
				.keyboardShortcut(",", modifiers: [.command])
#endif
			}
#endif
			.navigationTitle("Prof. Monster")
	}
}
