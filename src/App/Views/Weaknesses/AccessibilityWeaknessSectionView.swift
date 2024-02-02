import SwiftUI

@available(macOS, unavailable)
struct AccessibilityWeaknessSectionView: View {
	let viewModel: WeaknessSectionViewModel

	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0

	@Namespace
	private var namespace

	var body: some View {
#if os(watchOS)
		Section {
			if viewModel.options.physical {
				SeparatedPhysicalWeaknessSectionView(namespace: namespace,
													 viewModel: viewModel.physical)
			}

			if let elements = viewModel.elements {
				ElementWeaknessItemView(viewModel: elements.fire)
				ElementWeaknessItemView(viewModel: elements.water)
				ElementWeaknessItemView(viewModel: elements.thunder)
				ElementWeaknessItemView(viewModel: elements.ice)
				ElementWeaknessItemView(viewModel: elements.dragon)
			}
		} header: {
			if viewModel.isDefault {
				MASectionHeader("Weakness")
			} else {
				Text(viewModel.header)
			}
		}
#else
		if !viewModel.isDefault {
			MAItemHeader(header: viewModel.header)
		}

		MAFormMetricsBuilder { metrics in
			MAFormRoundedBackground(metrics) {
				if viewModel.options.physical {
					SeparatedPhysicalWeaknessSectionView(namespace: namespace,
														 viewModel: viewModel.physical)
						.preferredVerticalPadding()
				}

				if let elements = viewModel.elements {
					let fractionLength = viewModel.options.element.fractionLength
					Group {
						ElementWeaknessItemView(signFontSize: signFontSize, fractionLength: fractionLength, viewModel: elements.fire)
						ElementWeaknessItemView(signFontSize: signFontSize, fractionLength: fractionLength, viewModel: elements.water)
						ElementWeaknessItemView(signFontSize: signFontSize, fractionLength: fractionLength, viewModel: elements.thunder)
						ElementWeaknessItemView(signFontSize: signFontSize, fractionLength: fractionLength, viewModel: elements.ice)
						ElementWeaknessItemView(signFontSize: signFontSize, fractionLength: fractionLength, viewModel: elements.dragon)
					}
					.preferredVerticalPadding()
				}
			}
		}
#endif
	}
}
