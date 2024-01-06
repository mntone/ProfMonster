import SwiftUI

struct SharedSettingsPaneModifier: ViewModifier {
	func body(content: Content) -> some View {
		let base = content
#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
		return base
	}
}
