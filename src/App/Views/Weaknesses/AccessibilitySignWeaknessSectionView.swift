#if os(iOS) || os(watchOS)

import SwiftUI

@available(macOS, unavailable)
private struct _AccessibilitySignWeaknessItemView<ViewModel: WeaknessItemViewModel>: View {
#if os(iOS)
	let signFontSize: CGFloat
#endif
	let namespace: Namespace.ID
	let viewModel: ViewModel

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 0) {
			Text(viewModel.attack.label(.medium))
				.foregroundStyle(viewModel.attack.color)
				.accessibilityLabeledPair(role: .label, id: viewModel.id, in: namespace)
				.accessibilityLabel(viewModel.attack.label(.long))

			Spacer()

			Text(viewModel.effectiveness.label)
				.foregroundStyle(viewModel.signColor)
#if os(watchOS)
				.font(.systemBackport(.body,
									  design: .rounded,
									  weight: viewModel.signWeight).leading(.tight))
#else
				.font(.system(size: signFontSize,
							  weight: viewModel.signWeight,
							  design: .rounded))
#endif
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
				.accessibilityLabeledPair(role: .content, id: viewModel.id, in: namespace)
				.accessibilityLabel(Text(viewModel.effectiveness.accessibilityLabel))
		}
		.accessibilityElement(children: .combine)
	}
}

@available(macOS, unavailable)
struct AccessibilitySignWeaknessSectionView<ViewModel: WeaknessSectionViewModel>: View {
	let viewModel: ViewModel

#if !os(macOS)
	@ScaledMetric(relativeTo: .title2)
	private var signFontSize: CGFloat = 22.0
#endif

	@Namespace
	private var namespace

	var body: some View {
#if os(watchOS)
		Section {
			ForEach(viewModel.items) { item in
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: item)
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
				ForEach(viewModel.items) { item in
					_AccessibilitySignWeaknessItemView(signFontSize: signFontSize,
													   namespace: namespace,
													   viewModel: item)
						.preferredVerticalPadding()
				}
			}
		}
#endif
	}
}

#endif
