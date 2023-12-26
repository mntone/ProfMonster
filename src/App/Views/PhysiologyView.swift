import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyRowView: View {
	let viewModel: PhysiologyViewModel
	let headerWidth: CGFloat
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			Text(verbatim: viewModel.header)
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: headerWidth)
				.accessibilityAddTraits(.isHeader)

			ForEach(viewModel.values) { item in
				Spacer(minLength: PhysiologyViewMetrics.spacing)

				let text = Text(verbatim: String(item.value))
				text
					.frame(width: itemWidth)
					.accessibilityLabel(item.attack.accessibilityLabel)
					.accessibilityValue(text)
			}
		}
		.foregroundStyle(viewModel.foregroundShape)
		.accessibilityElement(children: .contain)
		.accessibilityLabel(Text(verbatim: viewModel.header))
	}
}

private struct PhysiologyRowHeaderView: View {
	let viewModel: [PhysiologyColumnViewModel]
	let headerWidth: CGFloat
	let itemWidth: CGFloat

	var body: some View {
		HStack(spacing: 0) {
			ForEach(viewModel) { item in
				Spacer(minLength: PhysiologyViewMetrics.spacing)
				Image(systemName: item.attack.imageName)
					.foregroundStyle(item.attack.color)
					.frame(width: itemWidth)
			}
		}
		.padding(EdgeInsets(top: PhysiologyViewMetrics.rowSpacing,
							leading: PhysiologyViewMetrics.inset + headerWidth,
							bottom: PhysiologyViewMetrics.rowSpacing,
							trailing: PhysiologyViewMetrics.inset))
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
				Text(verbatim: viewModel.header)
					.font(.system(.subheadline).weight(.medium))
					.accessibilityAddTraits(.isHeader)
			}

#if os(macOS)
			PhysiologyRowHeaderView(viewModel: viewModel.columns,
									headerWidth: PhysiologyViewMetrics.headerBaseWidth,
									itemWidth: PhysiologyViewMetrics.itemBaseWidth)
#else
			PhysiologyRowHeaderView(viewModel: viewModel.columns,
									headerWidth: headerWidth,
									itemWidth: itemWidth)
#endif

			ForEach(viewModel.groups) { group in
				VStack(spacing: 0) {
					ForEach(group.items) { item in
#if os(macOS)
						PhysiologyRowView(viewModel: item,
										  headerWidth: PhysiologyViewMetrics.headerBaseWidth,
										  itemWidth: PhysiologyViewMetrics.itemBaseWidth)
#else
						PhysiologyRowView(viewModel: item,
										  headerWidth: headerWidth,
										  itemWidth: itemWidth)
#endif
					}
				}
				.padding(EdgeInsets(top: PhysiologyViewMetrics.rowSpacing,
									leading: PhysiologyViewMetrics.inset,
									bottom: PhysiologyViewMetrics.rowSpacing,
									trailing: PhysiologyViewMetrics.inset))
				.background(group.id % 2 != 0
							? RoundedRectangle(cornerRadius: 4).foregroundColor(.physiologySecondary).accessibilityHidden(true)
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
