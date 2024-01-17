import SwiftUI

@available(watchOS, unavailable)
struct NumberWeaknessSectionView: View {
	let fractionLength: Int
	let viewModel: NumberWeaknessSectionViewModel

#if !os(macOS)
	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0
#endif

	@State
	private var itemWidth: CGFloat?

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		let signFontSize = 22.0
#endif
		VStack(alignment: .leading, spacing: 5) {
			if !viewModel.isDefault {
				DetailItemHeader(header: viewModel.header)
			}

			DividedHStack(alignment: .lastTextBaseline, spacing: 0) {
				ForEach(viewModel.items) { item in
					NumberWeaknessItemView(fractionLength: fractionLength,
										   signFontSize: signFontSize,
										   namespace: namespace,
										   viewModel: item)
				}
				.padding(.horizontal, 8)
				.frame(minWidth: 0,
					   idealWidth: itemWidth,
					   maxWidth: WeaknessViewMetrics.maxItemWidth,
					   alignment: .leading)
			}
			.padding(.horizontal, -8)
			.fixedSize(horizontal: false, vertical: true)
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
		}
	}

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(WeaknessViewMetrics.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}
}
