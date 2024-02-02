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

private struct _SignElementWeaknessStyle: LabelStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .center, spacing: 0.0) {
			configuration.icon

			Spacer(minLength: 0)

			configuration.title
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
#if !os(watchOS)
				.background(.formItemBackground)
#endif
		}
#if os(watchOS)
		.frame(maxWidth: .infinity)
#endif
	}
}

#if !os(watchOS)
@available(watchOS, unavailable)
private struct _NumberElementWeaknessStyle: LabelStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		VStack(alignment: .leading, spacing: 0.0) {
			configuration.icon

			Spacer(minLength: 0)

			configuration.title
				.lineLimit(1)
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
#if !os(watchOS)
				.background(.formItemBackground)
#endif
		}
#if os(watchOS)
		.frame(maxWidth: .infinity)
#endif
	}
}
#endif

#if os(iOS) || os(watchOS)
@available(macOS, unavailable)
private struct _AccessibilityElementWeaknessStyle: LabelStyle {
	@ViewBuilder
	func makeBody(configuration: Configuration) -> some View {
		HStack(alignment: .firstTextBaseline, spacing: 0.0) {
			configuration.icon

			Spacer(minLength: 0)

			configuration.title
				.monospacedDigit()
				.lineLimit(1)
#if !os(macOS)
				.minimumScaleFactor(0.5)
#endif
#if !os(watchOS)
				.background(.formItemBackground)
#endif
		}
#if os(watchOS)
		.frame(maxWidth: .infinity)
#endif
	}
}
#endif

struct ElementWeaknessItemView: View {
#if !os(watchOS)
	let signFontSize: CGFloat
	let fractionLength: Int
#endif
	let viewModel: ElementWeaknessItemViewModel

#if os(iOS) || os(watchOS)
	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize
#endif

	var body: some View {
		Label {
#if os(watchOS)
			Text(viewModel.effectiveness.label)
				.foregroundStyle(viewModel.signColor)
				.font(.systemBackport(.body,
									  design: .rounded,
									  weight: viewModel.signWeight).leading(.tight))
#else
			if fractionLength > 0,
			   let number = viewModel.average {
				WeaknessViewMetrics.getComplexNumberText(Float32(number),
														 length: fractionLength,
														 baseSize: signFontSize,
														 weight: viewModel.signWeight)
			} else {
				Text(viewModel.effectiveness.label)
					.foregroundStyle(viewModel.signColor)
					.font(.system(size: signFontSize,
								  weight: viewModel.signWeight,
								  design: .rounded))
			}
#endif
		} icon: {
#if os(iOS) || os(watchOS)
			if isAccessibilitySize {
				Text(viewModel.element.label(.medium))
					.foregroundStyle(viewModel.element.color)
			} else {
				viewModel.element.image
					.foregroundStyle(viewModel.element.color)
			}
#else
			viewModel.element.image
				.foregroundStyle(viewModel.element.color)
#endif
		}
		.accessibilityLabel(viewModel.element.label(.medium))
		.accessibilityValue(viewModel.effectiveness.accessibilityLabel)
		.block { content in
#if os(macOS)
			if fractionLength > 0 {
				content.labelStyle(_NumberElementWeaknessStyle())
			} else {
				content.labelStyle(_SignElementWeaknessStyle())
			}
#else
			if isAccessibilitySize {
				content.labelStyle(_AccessibilityElementWeaknessStyle())
			} else {
#if os(watchOS)
				content.labelStyle(_SignElementWeaknessStyle())
#else
				if fractionLength > 0 {
					content.labelStyle(_NumberElementWeaknessStyle())
				} else {
					content.labelStyle(_SignElementWeaknessStyle())
				}
#endif
			}
#endif
		}
	}
}
