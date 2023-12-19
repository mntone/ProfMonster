import enum MonsterAnalyzerCore.Sort
import SwiftUI

struct SharedGameListModifier: ViewModifier {
	let isLoading: Bool
	let settingsAction: () -> Void

	func body(content: Content) -> some View {
		content
#if !os(macOS)
			.leadingToolbarItemBackport {
				Button("Settings", systemImage: "gearshape.fill", action: settingsAction)
#if !os(watchOS)
				.keyboardShortcut(",", modifiers: [.command])
#endif
			}
#endif
			.overlay {
				if isLoading {
					ProgressView()
				}
			}
			.navigationTitle("Prof. Monster")
	}
}
