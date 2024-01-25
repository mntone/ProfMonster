import SwiftUI

@available(watchOS, unavailable)
struct NumberWeaknessSectionView: View {
	let fractionLength: Int
	let viewModel: NumberWeaknessSectionViewModel

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

#if !os(macOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 11

	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0
#endif

	@State
	private var itemWidth: CGFloat?

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		let spacing = MAFormMetrics.verticalRowInset
		let signFontSize = 22.0
		let padding = horizontalLayoutMargin
#else
		let padding = 0.5 * horizontalLayoutMargin
#endif
		let hasHeader = !viewModel.isDefault
		MAFormMetricsBuilder { metrics in
			MAFormRoundedBackground(metrics, header: hasHeader) {
				if hasHeader {
					MAItemHeader(header: viewModel.header)
						.padding(.top, spacing)
				}

				if viewModel.options.physical {
					PhysicalWeaknessSectionView(padding: padding,
												namespace: namespace,
												viewModel: viewModel.physical)
						.padding(.vertical, spacing)
				}

				if !viewModel.items.isEmpty {
					DividedHStack(alignment: .bottom, spacing: 0) {
						ForEach(viewModel.items) { item in
							NumberWeaknessItemView(fractionLength: fractionLength,
												   signFontSize: signFontSize,
												   namespace: namespace,
												   viewModel: item)
						}
						.lineLimit(1)
						.padding(.horizontal, padding)
						.frame(minWidth: 0,
							   idealWidth: itemWidth,
							   maxWidth: WeaknessViewMetrics.maxItemWidth,
							   alignment: .leading)
					} divider: {
						MAVDivider()
					}
					.padding(EdgeInsets(vertical: spacing, horizontal: -padding))
					.onWidthChange { width in
						updateItemWidth(from: width)
					}
				}
			}
		}
	}

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(WeaknessViewMetrics.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}
}
