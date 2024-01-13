import SwiftUI

struct _PreferredVerticalPaddingModifier: ViewModifier {
#if os(iOS)
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
			return 0.0
		}
	}
#else
	func body(content: Content) -> some View {
		content
	}
#endif
}

extension View {
	@ViewBuilder
	func preferredVerticalPadding() -> ModifiedContent<Self, _PreferredVerticalPaddingModifier> {
		modifier(_PreferredVerticalPaddingModifier())
	}
}
