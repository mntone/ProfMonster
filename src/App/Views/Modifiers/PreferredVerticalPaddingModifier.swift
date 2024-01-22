import SwiftUI

#if os(iOS)

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _PreferredVerticalPaddingModifier: ViewModifier {
	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0

	func body(content: Content) -> some View {
		content.padding(EdgeInsets(vertical: verticalPadding,
								   horizontal: 0.0))
	}
}

#endif

@available(watchOS, unavailable)
extension View {
#if os(macOS)
	@inline(__always)
	@ViewBuilder
	func preferredVerticalPadding() -> some View {
		padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 10.0, trailing: 0.0))
	}
#else
	@inline(__always)
	@ViewBuilder
	func preferredVerticalPadding() -> ModifiedContent<Self, _PreferredVerticalPaddingModifier> {
		modifier(_PreferredVerticalPaddingModifier())
	}
#endif
}

