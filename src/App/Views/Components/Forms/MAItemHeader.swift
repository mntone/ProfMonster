import SwiftUI

struct MAItemHeader: View {
	let header: String

#if os(iOS) || os(macOS)
	@Environment(\.defaultListSectionSpacing)
	private var defaultListSectionSpacing

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\._ignoreLayoutMargin)
	private var ignoreLayoutMargin

	@Environment(\._inOwnerdrawBackgroundContext)
	private var inBackgroundContext

	@Environment(\.pixelLength)
	private var pixelLength
#endif

	var body: some View {
#if os(iOS) || os(macOS)
		let horizontalPadding = !inBackgroundContext || ignoreLayoutMargin ? horizontalLayoutMargin : 0.0
#endif
		Text(header)
#if os(iOS) || os(macOS)
			.font(.system(.headline))
			.padding(EdgeInsets(top: inBackgroundContext ? 0.0 : pixelLength * round(0.75 * defaultListSectionSpacing / pixelLength),
								leading: horizontalPadding,
								bottom: inBackgroundContext ? 0.0 : MAFormMetrics.verticalRowInset,
								trailing: horizontalPadding))
#else
			.font(.system(.subheadline))
			.scenePadding(.horizontal)
#endif
			.accessibilityAddTraits(.isHeader)
	}
}
