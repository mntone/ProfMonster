import SwiftUI

struct SignWeaknessSectionView<ViewModel: WeaknessSectionViewModel>: View {
#if !os(watchOS)
	let alignment: HorizontalAlignment
#endif
	let viewModel: ViewModel

	@State
	private var itemWidth: CGFloat?

#if !os(watchOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

#if os(iOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 11

	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22
#endif

	@Namespace
	private var namespace

	var body: some View {
#if os(watchOS)
		Section {
			HStack(alignment: .bottom, spacing: 0) {
				ForEach(viewModel.items) { item in
					SignWeaknessItemView(namespace: namespace,
										 viewModel: item)
				}
				.frame(width: itemWidth)
			}
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
		} header: {
			if viewModel.isDefault {
				MASectionHeader("Weakness")
			} else {
				Text(viewModel.header)
			}
		}
#else
#if os(macOS)
		let spacing = 5.0
		let signFontSize = 22.0
		let padding = horizontalLayoutMargin
#else
		let padding = 0.5 * horizontalLayoutMargin
#endif
		VStack(alignment: .leading, spacing: spacing) {
			if !viewModel.isDefault {
				MAItemHeader(header: viewModel.header)
			}

			DividedHStack(alignment: .bottom, spacing: 0) {
				ForEach(viewModel.items) { item in
					SignWeaknessItemView(alignment: alignment,
										 signFontSize: signFontSize,
										 namespace: namespace,
										 viewModel: item)
				}
				.padding(.horizontal, padding)
				.frame(minWidth: 0,
					   idealWidth: itemWidth,
					   maxWidth: WeaknessViewMetrics.maxItemWidth,
					   alignment: Alignment(horizontal: alignment, vertical: .center))
			} divider: {
				MAVDivider()
			}
			.padding(.horizontal, -padding)
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
		}
#endif
	}

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(WeaknessViewMetrics.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}
}
