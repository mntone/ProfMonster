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

#if os(iOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 2.75
#endif

	var body: some View {
#if os(macOS)
		let spacing = pixelLength * round(2.5 / pixelLength)
#endif
#if os(iOS) || os(macOS)
		let horizontalPadding = !inBackgroundContext || ignoreLayoutMargin ? horizontalLayoutMargin : 0.0
#endif
		Text(header)
			.font(.system(.headline))
#if os(iOS) || os(macOS)
			.padding(EdgeInsets(top: inBackgroundContext ? 0.0 : pixelLength * round(0.75 * defaultListSectionSpacing / pixelLength),
								leading: horizontalPadding,
								bottom: inBackgroundContext ? spacing : MAFormMetrics.verticalRowInset,
								trailing: horizontalPadding))
#endif
			.accessibilityAddTraits(.isHeader)
	}
}
