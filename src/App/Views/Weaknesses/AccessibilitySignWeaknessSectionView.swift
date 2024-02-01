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
			Text(viewModel.element.label(.medium))
				.foregroundStyle(viewModel.element.color)
				.accessibilityLabeledPair(role: .label, id: viewModel.id, in: namespace)
				.accessibilityLabel(viewModel.element.label(.long))

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
#if !os(watchOS)
				.background(.formItemBackground)
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
			if viewModel.options.physical {
				SeparatedPhysicalWeaknessSectionView(namespace: namespace,
													 viewModel: viewModel.physical)
			}

			if let elements = viewModel.elements {
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: elements.fire)
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: elements.water)
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: elements.thunder)
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: elements.ice)
				_AccessibilitySignWeaknessItemView(namespace: namespace, viewModel: elements.dragon)
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
					Group {
						_AccessibilitySignWeaknessItemView(signFontSize: signFontSize, namespace: namespace, viewModel: elements.fire)
						_AccessibilitySignWeaknessItemView(signFontSize: signFontSize, namespace: namespace, viewModel: elements.water)
						_AccessibilitySignWeaknessItemView(signFontSize: signFontSize, namespace: namespace, viewModel: elements.thunder)
						_AccessibilitySignWeaknessItemView(signFontSize: signFontSize, namespace: namespace, viewModel: elements.ice)
						_AccessibilitySignWeaknessItemView(signFontSize: signFontSize, namespace: namespace, viewModel: elements.dragon)
					}
					.preferredVerticalPadding()
				}
			}
		}
#endif
	}
}
