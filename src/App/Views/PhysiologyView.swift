import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyRowView: View {
	let viewModel: PhysiologyViewModel

#if !os(macOS)
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth
#endif

	var body: some View {
		HStack {
			Text(verbatim: viewModel.header)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
#if os(macOS)
				.frame(width: PhysiologyViewMetrics.headerBaseWidth)
#else
				.frame(width: headerWidth)
#endif
			ForEach(Array(viewModel.value.values().enumerated()), id: \.offset) { _, val in
				Spacer()
				Text(verbatim: String(val))
#if os(macOS)
					.frame(width: PhysiologyViewMetrics.itemBaseWidth)
#else
					.frame(width: itemWidth)
#endif
			}
		}
		.foregroundColor(viewModel.foregroundColor)
	}
}

struct PhysiologySectionView: View {
	let viewModel: PhysiologyGroupViewModel

	var body: some View {
		VStack(spacing: 0) {
			ForEach(viewModel.items) { item in
				PhysiologyRowView(viewModel: item)
			}
		}
	}
}

struct PhysiologyView: View {
	let viewModel: PhysiologySectionViewModel

	var body: some View {
		VStack(spacing: 0) {
			ForEach(Array(viewModel.groups.enumerated()), id: \.offset) { i, group in
				PhysiologySectionView(viewModel: group)
					.padding(EdgeInsets(top: PhysiologyViewMetrics.spacing,
										leading: PhysiologyViewMetrics.inset,
										bottom: PhysiologyViewMetrics.spacing,
										trailing: PhysiologyViewMetrics.inset))
					.background(i % 2 != 0
								? RoundedRectangle(cornerRadius: 4).foregroundColor(.physiologySecondary)
								: nil)
			}
		}
		.font(Font.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
		.frame(idealWidth: PhysiologyViewMetrics.maxWidth,
			   maxWidth: PhysiologyViewMetrics.maxWidth)
	}
}

#Preview {
	PhysiologyView(viewModel: PhysiologiesViewModel(rawValue: MockDataSource.physiology1).sections[0])
		.previewLayout(.sizeThatFits)
}
