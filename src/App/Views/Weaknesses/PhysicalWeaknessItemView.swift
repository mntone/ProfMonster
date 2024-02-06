import enum MonsterAnalyzerCore.Physical
import SwiftUI

@available(watchOS, unavailable)
struct PhysicalWeaknessItemView: View {
	private static let placeholder: Text = {
		Text(verbatim: "???")
	}()

	private static let separator: Text = {
		Text(", ")
	}()

	private static let none: Text = {
		let baseText = Text("None").fontWeight(.light)
		if #available(iOS 17.0, macOS 14.0, *) {
			return baseText.foregroundStyle(.secondary)
		} else {
			return baseText.foregroundColor(.secondary)
		}
	}()

#if os(macOS)
	private static var font: Font {
		.body
	}
#else
	private static var font: Font {
		.subheadline
	}
#endif

	let viewModel: PhysicalWeaknessItemViewModel?
	let physical: Physical

#if !os(macOS)
	@ScaledMetric(relativeTo: .subheadline)
	private var offsetX: CGFloat = 22.5
#endif

	var body: some View {
		ZStack(alignment: .leadingFirstTextBaseline) {
			Image(physical.imageResource)
				.foregroundStyle(.secondary)
				.accessibilityLabel(physical.label(.medium))
				.alignmentGuide(.firstTextBaseline) { d in
					0.75 * d[.bottom]
				}

			content
				.font(Self.font)
				.redacted(reason: viewModel == nil ? .placeholder : [])
#if os(macOS)
				.offset(x: viewModel == nil ? 21.0 : 0.0)
#else
				.offset(x: viewModel == nil ? offsetX : 0.0)
#endif
		}
		.accessibilityElement(children: .combine)
		.id(viewModel?.id ?? physical.prefix)
	}

	private var content: Text {
		guard let viewModel else {
			return Self.placeholder
		}

		if !viewModel.firstPartNames.isEmpty {
			let first = Text(verbatim: "      ") + Text(viewModel.firstPartNames)
			if !viewModel.secondPartNames.isEmpty {
				let second = PhysicalWeaknessItemView.separator + Text(viewModel.secondPartNames)
				if #available(iOS 17.0, macOS 14.0, *) {
					return first + second.foregroundStyle(.secondary)
				} else {
					return first + second.foregroundColor(.secondary)
				}
			} else {
				return first
			}
		} else {
			return Text(verbatim: "      ") + Self.none
		}
	}
}
