import SwiftUI

struct WeaknessSectionView: View {
	let viewModel: WeaknessSectionViewModel

#if !os(watchOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\.pixelLength)
	private var pixelLength
#endif

#if os(watchOS)
	@State
	private var itemWidth: CGFloat?
#else
	@State
	private var physicalWidth: CGFloat = 80.0

	@State
	private var elementWidth: CGFloat = 48.0
#endif

#if os(iOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 11

	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22
#endif

	@Namespace
	private var namespace

#if os(watchOS)
	var body: some View {
		Section {
			if viewModel.options.physical {
				SeparatedPhysicalWeaknessSectionView(namespace: namespace,
													 viewModel: viewModel.physical)
			}

			if let elements = viewModel.elements {
				HStack(alignment: .bottom, spacing: 0) {
					Group {
						ElementWeaknessItemView(viewModel: elements.fire)
						ElementWeaknessItemView(viewModel: elements.water)
						ElementWeaknessItemView(viewModel: elements.thunder)
						ElementWeaknessItemView(viewModel: elements.ice)
						ElementWeaknessItemView(viewModel: elements.dragon)
					}
					.frame(width: itemWidth)
				}
				.onWidthChange { width in
					itemWidth = 0.2 * width
				}
				.fixedSize(horizontal: false, vertical: true)
			}
		} header: {
			if viewModel.isDefault {
				MASectionHeader(LocalizedStringKey("Weakness"))
			} else {
				Text(viewModel.header)
			}
		}
	}
#else
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
					DividedHStack(alignment: .top, spacing: 0.0) {
						Group {
							PhysicalWeaknessItemView(viewModel: viewModel.physical?.slash,
													 physical: .slash)
							PhysicalWeaknessItemView(viewModel: viewModel.physical?.impact,
													 physical: .impact)
							PhysicalWeaknessItemView(viewModel: viewModel.physical?.shot,
													 physical: .shot)
						}
						.padding(.horizontal, padding)
						.frame(idealWidth: physicalWidth,
							   maxWidth: WeaknessViewMetrics.maxPhysicalContentWidth,
							   maxHeight: .infinity,
							   alignment: .topLeading)
					} divider: {
						MAVDivider()
					}
					.padding(EdgeInsets(vertical: spacing, horizontal: -padding))
					.onWidthChange { width in
						physicalWidth = min(
							pixelLength * floor((width + 2.0 * padding) / 3.0 / pixelLength),
							WeaknessViewMetrics.maxPhysicalContentWidth)
					}
				}

				if let elements = viewModel.elements {
					let fractionLength = viewModel.options.element.fractionLength
					DividedHStack(alignment: .bottom, spacing: 0.0) {
						Group {
							ElementWeaknessItemView(signFontSize: signFontSize,
													fractionLength: fractionLength,
													viewModel: elements.fire)
							ElementWeaknessItemView(signFontSize: signFontSize,
													fractionLength: fractionLength,
													viewModel: elements.water)
							ElementWeaknessItemView(signFontSize: signFontSize,
													fractionLength: fractionLength,
													viewModel: elements.thunder)
							ElementWeaknessItemView(signFontSize: signFontSize,
													fractionLength: fractionLength,
													viewModel: elements.ice)
							ElementWeaknessItemView(signFontSize: signFontSize,
													fractionLength: fractionLength,
													viewModel: elements.dragon)
						}
						.padding(.horizontal, padding)
						.frame(idealWidth: elementWidth,
							   maxWidth: WeaknessViewMetrics.maxItemWidth,
							   maxHeight: .infinity,
							   alignment: viewModel.options.element == .sign ? .center : .leading)
					} divider: {
						MAVDivider()
					}
					.padding(EdgeInsets(vertical: spacing, horizontal: -padding))
					.onWidthChange { width in
						elementWidth = min(
							pixelLength * floor(0.2 * (width + 2.0 * padding) / pixelLength),
							WeaknessViewMetrics.maxItemWidth)
					}
				}
			}
		}
	}
#endif
}
