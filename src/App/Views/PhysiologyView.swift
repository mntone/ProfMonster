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

			ForEach(Array(viewModel.values.enumerated()), id: \.offset) { _, val in
				Spacer(minLength: PhysiologyViewMetrics.spacing)
				Text(verbatim: String(val))
					.frame(width: itemWidth)
			}
		}
		.foregroundStyle(viewModel.foregroundShape)
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
				Image(systemName: item.attackImageName)
					.foregroundStyle(item.attackColor)
					.frame(width: itemWidth)
			}
		}
		.padding(EdgeInsets(top: PhysiologyViewMetrics.rowSpacing,
							leading: PhysiologyViewMetrics.inset + headerWidth,
							bottom: PhysiologyViewMetrics.rowSpacing,
							trailing: PhysiologyViewMetrics.inset))
	}
}

struct PhysiologyView: View {
	let viewModel: PhysiologySectionViewModel

#if !os(macOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth
#endif

	var body: some View {
		VStack(spacing: 0) {
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
							? RoundedRectangle(cornerRadius: 4).foregroundColor(.physiologySecondary)
							: nil)
			}
		}
		.multilineTextAlignment(.center)
		.font(Font.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
		.frame(idealWidth: PhysiologyViewMetrics.maxWidth,
			   maxWidth: PhysiologyViewMetrics.maxWidth)
	}
}

#Preview {
	PhysiologyView(viewModel: PhysiologiesViewModel(rawValue: MockDataSource.physiology1).sections[0])
		.previewLayout(.sizeThatFits)
}
