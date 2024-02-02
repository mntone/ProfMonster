import enum MonsterAnalyzerCore.Physical
import SwiftUI

@available(watchOS, unavailable)
struct PhysicalWeaknessItemView: View {
	private static let separator: String = {
		String(localized: ", ")
	}()

	private static let none: String = {
		String(localized: "None")
	}()

#if os(macOS)
	private static var font: Font {
		.body
	}

	private static var secondaryColor: NSColor {
		NSColor.secondaryLabelColor
	}
#else
	private static var font: Font {
		.subheadline
	}

	private static var secondaryColor: UIColor {
		UIColor.secondaryLabel
	}
#endif

	private static let attributes: AttributeContainer = {
#if os(macOS)
		let attributes: [NSAttributedString.Key: Any] = [
			.font: NSFont.systemFont(ofSize: 13),
			.foregroundColor: NSColor.labelColor,
		]
#else
		let attributes: [NSAttributedString.Key: Any] = [
			.font: UIFont.preferredFont(forTextStyle: .subheadline),
			.foregroundColor: UIColor.label,
		]
#endif
		return AttributeContainer(attributes)
	}()

	let viewModel: PhysicalWeaknessItemViewModel?
	let physical: Physical

#if !os(macOS)
	@ScaledMetric(relativeTo: .subheadline)
	private var offsetX: CGFloat = 30.0
#endif

	var body: some View {
		ZStack(alignment: .leadingFirstTextBaseline) {
			physical.image
				.foregroundStyle(.secondary)
				.accessibilityLabel(physical.label(.medium))
				.alignmentGuide(.firstTextBaseline) { d in
					0.75 * d[.bottom]
				}

			Text(content.attributedString)
				.redacted(reason: viewModel == nil ? .placeholder : [])
#if os(macOS)
				.offset(x: viewModel == nil ? 28.0 : 0.0)
#else
				.offset(x: viewModel == nil ? offsetX : 0.0)
#endif
		}
		.accessibilityElement(children: .combine)
		.id(viewModel?.id ?? physical.prefix)
	}

	private var content: (text: String, attributedString: AttributedString) {
		guard let viewModel else {
			let placeholderText = "???"
			let placeholder = AttributedString(placeholderText, attributes: Self.attributes)
			return (placeholderText, placeholder)
		}

		if !viewModel.firstPartNames.isEmpty {
			let first = AttributedString("        " + viewModel.firstPartNames, attributes: Self.attributes)
			if !viewModel.secondPartNames.isEmpty {
				var attributes = Self.attributes
				attributes.foregroundColor = Self.secondaryColor

				let secondText = PhysicalWeaknessItemView.separator + viewModel.secondPartNames
				let second = AttributedString(secondText, attributes: attributes)
				return (viewModel.firstPartNames + secondText, first + second)
			} else {
				return (viewModel.firstPartNames, first)
			}
		} else {
			var attributes = Self.attributes
			attributes.foregroundColor = Self.secondaryColor
			attributes.font = Self.font.weight(.light)

			let noneText = Self.none
			let none = AttributedString("        " + noneText, attributes: attributes)
			return (noneText, none)
		}
	}
}
