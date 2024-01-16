import SwiftUI

@available(macOS 13.0, *)
struct SharedSettingsContainerModifier: ViewModifier {
#if os(iOS) || os(watchOS)
	let dismiss: () -> Void
#endif

	func body(content: Content) -> some View {
		content
#if os(macOS)
			.labelStyle(.settings)
#else
			.block { content in
				if #available(iOS 16.0, watchOS 9.0, *) {
					content.labelStyle(.settings)
				} else {
					content.labelStyle(.settingsBackport)
				}
			}
#endif
#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close", role: .cancel, action: dismiss)
				}
			}
#elseif os(watchOS)
			.block { content in
				if #available(watchOS 10.0, *) {
					content
				} else {
					content.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Close", role: .cancel, action: dismiss)
						}
					}
				}
			}
#endif
			.navigationTitle("Settings")
	}
}
