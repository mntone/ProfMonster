import SwiftUI

struct MAItemHeader: View {
	let header: String

#if os(iOS) || os(macOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\._ignoreLayoutMargin)
	private var ignoreLayoutMargin
#endif

	var body: some View {
		Text(header)
			.font(.system(.headline))
			.accessibilityAddTraits(.isHeader)
#if os(iOS) || os(macOS)
			.padding(.horizontal, ignoreLayoutMargin ? horizontalLayoutMargin : 0.0)
#endif
	}
}
