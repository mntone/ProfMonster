import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct SettingsButtonStyle: ButtonStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.foregroundStyle(.tint)
			.preferredVerticalPadding()
	}
}
