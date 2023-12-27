import MonsterAnalyzerCore
import SwiftUI

struct SharedGameListModifier<Data>: ViewModifier {
	let state: StarSwingsState<Data>
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
				switch state {
				case .loading:
					ProgressView()
				case let .failure(_, error):
					Text(error.label)
						.scenePadding()
				default:
					EmptyView()
				}
			}
			.navigationTitle("Prof. Monster")
	}
}
