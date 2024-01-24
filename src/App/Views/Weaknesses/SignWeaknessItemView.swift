import SwiftUI

extension Font {
	public static func systemBackport(_ style: Font.TextStyle, design: Font.Design? = nil, weight: Font.Weight? = nil) -> Font {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			system(style, design: design, weight: weight)
		} else {
			system(style, design: design ?? .default).weight(weight ?? .regular)
		}
	}
}

struct SignWeaknessItemView<ViewModel: WeaknessItemViewModel>: View {
#if !os(watchOS)
	let alignment: HorizontalAlignment
	let signFontSize: CGFloat
#endif
	let namespace: Namespace.ID
	let viewModel: ViewModel

	var body: some View {
#if os(watchOS)
		let alignment: HorizontalAlignment = .center
#endif
		VStack(alignment: alignment, spacing: 0) {
			viewModel.element.image
				.foregroundStyle(viewModel.element.color)
				.accessibilityLabeledPair(role: .label, id: viewModel.id, in: namespace)
				.accessibilityLabel(viewModel.element.label(.long))

#if !os(watchOS)
			Spacer(minLength: 0)
#endif

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
#if os(watchOS)
		.frame(maxWidth: .infinity)
#endif
	}
}
