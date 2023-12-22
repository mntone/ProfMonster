import SwiftUI

@available(macOS 13.0, *)
struct SharedSettingsContainerModifier: ViewModifier {
#if os(iOS) || os(watchOS)
	@Environment(\.dismiss)
	private var dismiss
#endif

	func body(content: Content) -> some View {
		content
			.labelStyle(.settings)
#if os(iOS)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Close", role: .cancel, action: dismiss.callAsFunction)
				}
			}
#elseif os(watchOS)
			.block { content in
				if #available(watchOS 10.0, *) {
					content
				} else {
					content.toolbar {
						ToolbarItem(placement: .cancellationAction) {
							Button("Close", role: .cancel, action: dismiss.callAsFunction)
						}
					}
				}
			}
#endif
			.navigationTitle("Settings")
	}
}
