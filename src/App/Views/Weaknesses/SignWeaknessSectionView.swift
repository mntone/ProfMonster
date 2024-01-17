import SwiftUI

struct SignWeaknessSectionView<ViewModel: WeaknessSectionViewModel>: View {
#if !os(watchOS)
	let alignment: HorizontalAlignment
#endif
	let viewModel: ViewModel

	@State
	private var itemWidth: CGFloat?

#if !os(watchOS)
	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22
#endif

	@Namespace
	private var namespace

	var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			if !viewModel.isDefault {
				DetailItemHeader(header: viewModel.header)
			}

#if os(watchOS)
			HStack(alignment: .bottom, spacing: 0) {
				ForEach(viewModel.items) { item in
					SignWeaknessItemView(namespace: namespace,
										 viewModel: item)
				}
				.frame(width: itemWidth)
			}
			.fixedSize(horizontal: false, vertical: true)
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
#else
			DividedHStack(alignment: .bottom, spacing: 0) {
				ForEach(viewModel.items) { item in
					SignWeaknessItemView(alignment: alignment,
										 signFontSize: signFontSize,
										 namespace: namespace,
										 viewModel: item)
				}
				.padding(.horizontal, 8)
				.frame(minWidth: 0,
					   idealWidth: itemWidth,
					   maxWidth: WeaknessViewMetrics.maxItemWidth,
					   alignment: Alignment(horizontal: alignment, vertical: .center))
			}
			.padding(.horizontal, -8)
			.fixedSize(horizontal: false, vertical: true)
			.onWidthChange { width in
				updateItemWidth(from: width)
			}
#endif
		}
	}

	private func updateItemWidth(from containerSize: CGFloat) {
		itemWidth = min(WeaknessViewMetrics.maxItemWidth, containerSize / CGFloat(viewModel.items.count))
	}
}
