import SwiftUI

@available(watchOS, unavailable)
struct NumberWeaknessSectionView: View {
	let fractionLength: Int
	let viewModel: NumberWeaknessSectionViewModel

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

#if !os(macOS)
	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0
#endif

	@State
	private var itemWidth: CGFloat?

	@Namespace
	private var namespace

	var body: some View {
		VStack(alignment: .leading, spacing: MAFormMetrics.verticalRowInset) {
			if !viewModel.isDefault {
				MAItemHeader(header: viewModel.header)
			}

#if os(macOS)
			let signFontSize = 22.0
			let padding = horizontalLayoutMargin
#else
			let padding = 0.5 * horizontalLayoutMargin
#endif
			DividedHStack(alignment: .bottom, spacing: 0) {
				ForEach(viewModel.items) { item in
					NumberWeaknessItemView(fractionLength: fractionLength,
										   signFontSize: signFontSize,
										   namespace: namespace,
										   viewModel: item)
				}
				.padding(.horizontal, padding)
				.frame(minWidth: 0,
					   idealWidth: itemWidth,
					   maxWidth: WeaknessViewMetrics.maxItemWidth,
					   alignment: .leading)
			} divider: {
				MAVDivider()
			}
			.padding(.horizontal, -padding)
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
		}
	}

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(WeaknessViewMetrics.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}
}
