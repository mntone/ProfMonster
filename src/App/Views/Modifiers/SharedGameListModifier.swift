import MonsterAnalyzerCore
import SwiftUI

struct SharedGameListModifier: ViewModifier {
	let settingsAction: () -> Void

	func body(content: Content) -> some View {
		content
#if !os(macOS)
			.toolbarItemBackport(alignment: .leading) {
				Button("Settings", systemImage: "gearshape.fill", action: settingsAction)
#if !os(watchOS)
				.keyboardShortcut(",", modifiers: [.command])
#endif
			}
#endif
			.navigationTitle("Prof. Monster")
	}
}
