import SwiftUI

@available(watchOS, unavailable)
struct NumberWeaknessItemView: View {
	let fractionLength: Int
	let signFontSize: CGFloat
	let namespace: Namespace.ID
	let viewModel: NumberWeaknessItemViewModel

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			viewModel.attack.image
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabeledPair(role: .label, id: viewModel.id, in: namespace)
				.accessibilityLabel(viewModel.attack.label(.long))

			Spacer(minLength: 0)

			WeaknessViewMetrics
				.getComplexNumberText(Float32(viewModel.averageValue),
									  length: fractionLength,
									  baseSize: signFontSize,
									  weight: viewModel.signWeight)
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
				.accessibilityLabeledPair(role: .content, id: viewModel.id, in: namespace)
		}
		.accessibilityElement(children: .combine)
	}
}
