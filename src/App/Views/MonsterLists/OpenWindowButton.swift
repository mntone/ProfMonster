import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
struct OpenWindowButton: View {
	let id: String

	@Environment(\.openWindow)
	private var openWindow

#if !os(macOS)
	@Environment(\.supportsMultipleWindows)
	private var supportsMultipleWindows
#endif

	var body: some View {
#if os(macOS)
		Button("Open In New Window", systemImage: "macwindow.badge.plus") {
			openWindow(value: id)
		}
#else
		if supportsMultipleWindows {
			Button("Open In New Window", systemImage: "square.split.2x1") {
				openWindow(value: id)
			}
		}
#endif
	}
}
