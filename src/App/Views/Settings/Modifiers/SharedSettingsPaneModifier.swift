import SwiftUI

struct SharedSettingsPaneModifier: ViewModifier {
	func body(content: Content) -> some View {
		let base = content
#if os(iOS)
			.buttonStyle(SettingsButtonStyle())
#endif
#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
		return base
	}
}
