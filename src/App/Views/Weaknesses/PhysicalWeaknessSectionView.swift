import enum MonsterAnalyzerCore.Physical
import SwiftUI

private struct _PhysicalWeaknessItemView: View {
#if os(macOS)
	private static let font: Font = .body
#else
	private static let font: Font = .subheadline
#endif

	let namespace: Namespace.ID
	let viewModel: PhysicalWeaknessItemViewModel?
	let physical: Physical

#if !os(macOS)
	@ScaledMetric(relativeTo: .body)
	private var offsetX: CGFloat = 32.0

	@ScaledMetric(relativeTo: .subheadline)
	private var offsetY: CGFloat = 1.0
#endif

	var body: some View {
		ZStack(alignment: .topLeading) {
			physical.image
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .label, id: physical.prefix, in: namespace)
				.accessibilityLabel(physical.label(.long))

			contentText
				.redacted(reason: viewModel == nil ? .placeholder : [])
#if os(macOS)
				.offset(x: viewModel == nil ? 28.0 : 0.0)
#else
				.offset(x: viewModel == nil ? offsetX : 0.0, y: offsetY)
#endif
				.transition(.opacity)
				.accessibilityLabeledPair(role: .content, id: physical.prefix, in: namespace)
		}
#if !os(macOS)
		.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: offsetY, trailing: 0.0))
#endif
		.accessibilityElement(children: .combine)
		.id(viewModel?.id ?? physical.prefix)
	}

	private var contentText: Text {
		guard let viewModel else { return Text(verbatim: "???") }

		if !viewModel.firstPartNames.isEmpty {
			let firstText = Text(verbatim: "        ") + Text(viewModel.firstPartNames)
			if #available(iOS 17.0, macOS 14.0, *) {
				if !viewModel.secondPartNames.isEmpty {
					return (firstText + (Text(", ") + Text(viewModel.secondPartNames)).foregroundStyle(.secondary)).font(Self.font)
				} else {
					return firstText.font(Self.font)
				}
			} else {
				if !viewModel.secondPartNames.isEmpty {
					return (firstText + (Text(", ") + Text(viewModel.secondPartNames)).foregroundColor(.secondary)).font(Self.font)
				} else {
					return firstText.font(Self.font)
				}
			}
		} else if #available(iOS 17.0, macOS 14.0, *) {
			return (Text(verbatim: "        ") + Text("None"))
				.font(Self.font.weight(.light))
				.foregroundStyle(.secondary)
		} else {
			return (Text(verbatim: "        ") + Text("None"))
				.font(Self.font.weight(.light))
				.foregroundColor(.secondary)
		}
	}
}

@available(watchOS, unavailable)
struct PhysicalWeaknessSectionView: View {
	let namespace: Namespace.ID
	let viewModel: PhysicalWeaknessSectionViewModel?

	var body: some View {
		_PhysicalWeaknessItemView(namespace: namespace,
								  viewModel: viewModel?.slash,
								  physical: .slash)
		_PhysicalWeaknessItemView(namespace: namespace,
								  viewModel: viewModel?.impact,
								  physical: .impact)
		_PhysicalWeaknessItemView(namespace: namespace,
								  viewModel: viewModel?.shot,
								  physical: .shot)
	}
}
