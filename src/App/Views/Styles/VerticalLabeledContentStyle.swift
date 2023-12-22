import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
struct VerticalLabeledContentStyle: LabeledContentStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading) {
			configuration.label
			configuration.content.foregroundStyle(.secondary)
		}
		.multilineTextAlignment(.leading)
	}
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension LabeledContentStyle where Self == VerticalLabeledContentStyle {
	static var vertical: VerticalLabeledContentStyle {
		Self()
	}
}
