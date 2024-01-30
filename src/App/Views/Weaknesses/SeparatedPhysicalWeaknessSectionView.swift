import enum MonsterAnalyzerCore.Physical
import SwiftUI

private struct _SeparatedPhysicalWeaknessItemView: View {
	let namespace: Namespace.ID
	let viewModel: PhysicalWeaknessItemViewModel?
	let physical: Physical

	var body: some View {
		HStack(spacing: 0) {
			Text(physical.label(.medium))
				.accessibilityLabeledPair(role: .label, id: physical.prefix, in: namespace)
				.accessibilityLabel(physical.label(.long))

			Spacer()

			contentText
				.redacted(reason: viewModel == nil ? .placeholder : [])
				.accessibilityLabeledPair(role: .content, id: physical.prefix, in: namespace)
		}
		.accessibilityElement(children: .combine)
		.id(viewModel?.id ?? physical.prefix)
	}

	private var contentText: Text {
		guard let viewModel else { return Text(verbatim: "???") }

		if !viewModel.firstPartNames.isEmpty {
			let firstText = Text(viewModel.firstPartNames)
			if #available(iOS 17.0, watchOS 10.0, *) {
				if !viewModel.secondPartNames.isEmpty {
					return firstText + (Text(", ") + Text(viewModel.secondPartNames)).foregroundStyle(.secondary)
				} else {
					return firstText
				}
			} else {
				if !viewModel.secondPartNames.isEmpty {
					return firstText + (Text(", ") + Text(viewModel.secondPartNames)).foregroundColor(.secondary)
				} else {
					return firstText
				}
			}
		} else if #available(iOS 17.0, watchOS 10.0, *) {
			return Text("None")
				.font(.body.weight(.light))
				.foregroundStyle(.secondary)
		} else {
			return Text("None")
				.font(.body.weight(.light))
				.foregroundColor(.secondary)
		}
	}
}

struct SeparatedPhysicalWeaknessSectionView: View {
	let namespace: Namespace.ID
	let viewModel: PhysicalWeaknessSectionViewModel?

	var body: some View {
		_SeparatedPhysicalWeaknessItemView(namespace: namespace,
										   viewModel: viewModel?.slash,
										   physical: .slash)
		_SeparatedPhysicalWeaknessItemView(namespace: namespace,
										   viewModel: viewModel?.impact,
										   physical: .impact)
		_SeparatedPhysicalWeaknessItemView(namespace: namespace,
										   viewModel: viewModel?.shot,
										   physical: .shot)
	}
}
