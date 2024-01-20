import SwiftUI

@available(watchOS, unavailable)
struct MAFormMetricsBuilder<Content: View>: View {
	@Environment(\.defaultListRowSpacing)
	private var defaultListRowSpacing

	@Environment(\.defaultMinListRowHeight)
	private var defaultMinListRowHeight

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\._ignoreLayoutMargin)
	private var ignoreLayoutMargin

	@ViewBuilder
	let content: (MAFormLayoutMetrics) -> Content

	var body: some View {
		content(metrics)
	}

	private var metrics: MAFormLayoutMetrics {
#if os(macOS)
		let metrics = MAFormLayoutMetrics(layoutMargin: ignoreLayoutMargin ? 0.0 : MAFormMetrics.horizontalRowInset,
										  minRowHeight: defaultMinListRowHeight,
										  rowSpacing: defaultListRowSpacing)
#else
		let metrics = MAFormLayoutMetrics(layoutMargin: ignoreLayoutMargin ? 0.0 : horizontalLayoutMargin,
										  minRowHeight: defaultMinListRowHeight,
										  rowSpacing: defaultListRowSpacing)
#endif
		return metrics
	}
}
