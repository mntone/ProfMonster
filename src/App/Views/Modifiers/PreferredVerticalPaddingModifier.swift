import SwiftUI

#if os(iOS)

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _PreferredVerticalPaddingModifier: ViewModifier {
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	func body(content: Content) -> some View {
		content.padding(.vertical, verticalPadding)
	}

	private var verticalPadding: CGFloat {
		switch dynamicTypeSize {
		case .accessibility1...:
			return 16.0
		case .xxLarge, .xxxLarge:
			return 8.0
		default:
			return 4.0
		}
	}
}

#endif

extension View {
#if os(iOS)
	@ViewBuilder
	func preferredVerticalPadding() -> ModifiedContent<Self, _PreferredVerticalPaddingModifier> {
		modifier(_PreferredVerticalPaddingModifier())
	}
#else
	func preferredVerticalPadding() -> Self {
		self
	}
#endif
}
