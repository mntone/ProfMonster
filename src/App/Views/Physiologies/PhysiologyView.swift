import MonsterAnalyzerCore
import SwiftUI

private struct _PhysiologyRowView: View {
	let viewModel: PhysiologyViewModel
	let headerWidth: CGFloat
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			Text(verbatim: viewModel.header)
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: headerWidth)
				.accessibilityHidden(true)

			ForEach(viewModel.values) { item in
				Spacer(minLength: PhysiologyViewMetrics.spacing)

				let text = Text(verbatim: String(item.value))
				text
					.frame(width: itemWidth)
					.accessibilityLabel(item.attack.label(.long))
					.accessibilityValue(text)
			}

			Spacer(minLength: PhysiologyViewMetrics.spacing)

			let stunLabel = viewModel.stunLabel
			Text(verbatim: stunLabel)
				.frame(width: itemWidth)
				.accessibilityLabel("Stun")
				.accessibilityValue(stunLabel)
		}
		.foregroundStyle(viewModel.foregroundShape)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(Text(verbatim: viewModel.accessibilityHeader))
	}
}

private struct _PhysiologyRowHeaderView: View {
	let viewModel: [PhysiologyColumnViewModel]
	let headerWidth: CGFloat
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			ForEach(viewModel) { item in
				Spacer(minLength: PhysiologyViewMetrics.spacing)
				Image(systemName: item.attack.imageName)
					.help(item.attack.label(.long))
					.foregroundStyle(item.attack.color)
					.frame(width: itemWidth)
			}

			Spacer(minLength: PhysiologyViewMetrics.spacing)
			Image(systemName: "star.fill")
				.help("Stun")
				.foregroundStyle(.thunder)
				.frame(width: itemWidth)
		}
		.padding(PhysiologyViewMetrics.padding.adding(leading: headerWidth))
		.accessibilityHidden(true)
	}
}

struct PhysiologyView: View {
	let viewModel: PhysiologySectionViewModel
	let headerHidden: Bool

#if !os(macOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth
#endif

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			if !headerHidden {
				DetailItemHeader(header: viewModel.header)
			}

#if os(macOS)
			_PhysiologyRowHeaderView(viewModel: viewModel.columns,
									 headerWidth: PhysiologyViewMetrics.headerBaseWidth,
									 itemWidth: PhysiologyViewMetrics.itemBaseWidth)
#else
			_PhysiologyRowHeaderView(viewModel: viewModel.columns,
									 headerWidth: headerWidth,
									 itemWidth: itemWidth)
#endif

			ForEach(viewModel.groups) { group in
				VStack(spacing: 0) {
					ForEach(group.items) { item in
#if os(macOS)
						_PhysiologyRowView(viewModel: item,
										   headerWidth: PhysiologyViewMetrics.headerBaseWidth,
										   itemWidth: PhysiologyViewMetrics.itemBaseWidth)
#else
						_PhysiologyRowView(viewModel: item,
										   headerWidth: headerWidth,
										   itemWidth: itemWidth)
#endif
					}
				}
				.padding(PhysiologyViewMetrics.padding)
				.background(group.id % 2 != 0
							? RoundedRectangle(cornerRadius: 4).foregroundColor(.physiologySecondary)
							: nil)
			}
		}
		.multilineTextAlignment(.center)
		.font(Font.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
		.frame(idealWidth: PhysiologyViewMetrics.maxWidth,
			   maxWidth: PhysiologyViewMetrics.maxWidth)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(Text(verbatim: viewModel.header))
	}
}

#Preview {
	PhysiologyView(viewModel: PhysiologiesViewModel(rawValue: MockDataSource.physiology1).sections[0], headerHidden: false)
		.previewLayout(.sizeThatFits)
}
