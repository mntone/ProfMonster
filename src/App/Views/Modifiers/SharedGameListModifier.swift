import SwiftUI

struct SharedGameListModifier: ViewModifier {
	let viewModel: HomeViewModel

	@Environment(\.showSettings)
	private var showSettings

	func body(content: Content) -> some View {
		content
#if !os(macOS)
			.toolbarItemBackport(alignment: .leading) {
				Button("Settings",
					   systemImage: "gearshape",
					   action: showSettings.callAsFunction)
#if !os(watchOS)
				.keyboardShortcut(",", modifiers: [.command])
#endif
			}
#endif
			.navigationTitle("Prof. Monster")
	}
}
