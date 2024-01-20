import SwiftUI

@available(watchOS, unavailable)
struct AccessibilityNumberWeaknessItemView: View {
	let fractionLength: Int
	let signFontSize: CGFloat
	let namespace: Namespace.ID
	let viewModel: NumberWeaknessItemViewModel

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 0) {
			Text(viewModel.attack.label(.medium))
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabeledPair(role: .label, id: viewModel.id, in: namespace)
				.accessibilityLabel(viewModel.attack.label(.long))

			Spacer()

			WeaknessViewMetrics
				.getComplexNumberText(Float32(viewModel.averageValue),
									  length: fractionLength,
									  baseSize: signFontSize,
									  weight: viewModel.signWeight)
				.monospacedDigit()
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
				.accessibilityLabeledPair(role: .content, id: viewModel.id, in: namespace)
		}
		.accessibilityElement(children: .combine)
	}
}

@available(watchOS, unavailable)
struct AccessibilityNumberWeaknessSectionView: View {
	let fractionLength: Int
	let viewModel: NumberWeaknessSectionViewModel

#if !os(macOS)
	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0
#endif

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		let signFontSize: CGFloat = 22.0
#endif
		if !viewModel.isDefault {
			MAItemHeader(header: viewModel.header)
		}

		MAFormMetricsBuilder { metrics in
			MAFormRoundedBackground(metrics) {
				ForEach(viewModel.items) { item in
					AccessibilityNumberWeaknessItemView(fractionLength: fractionLength,
														signFontSize: signFontSize,
														namespace: namespace,
														viewModel: item)
						.preferredVerticalPadding()
				}
			}
		}
	}
}
