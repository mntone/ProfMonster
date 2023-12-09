import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyRowView: View {
	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var headerWidth: CGFloat = PhysiologyViewMetrics.headerBaseWidth

	@ScaledMetric(relativeTo: PhysiologyViewMetrics.textStyle)
	private var itemWidth: CGFloat = PhysiologyViewMetrics.itemBaseWidth

	private let viewModel: PhysiologyItemViewModel

	init(_ viewModel: PhysiologyItemViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		HStack {
			Text(verbatim: viewModel.header)
				.multilineTextAlignment(.center)
				.fixedSize(horizontal: false, vertical: true)
				.frame(width: headerWidth)

			ForEach(Array(viewModel.values.enumerated()), id: \.offset) { _, val in
				Spacer()
				Text(verbatim: String(val))
					.frame(width: itemWidth)
			}
		}
		.foregroundColor(viewModel.foregroundColor)
	}
}

struct PhysiologySectionView: View {
	private let viewModel: PhysiologySectionViewModel

	init(_ viewModel: PhysiologySectionViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack(spacing: 0) {
			ForEach(viewModel.items) { item in
				PhysiologyRowView(item)
			}
		}
	}
}

struct PhysiologyView: View {
	private let viewModel: PhysiologyViewModel

	init(_ viewModel: PhysiologyViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack(spacing: 0) {
			ForEach(Array(viewModel.sections.enumerated()), id: \.offset) { i, section in
				PhysiologySectionView(section)
					.padding(EdgeInsets(top: PhysiologyViewMetrics.spacing,
										leading: PhysiologyViewMetrics.inset,
										bottom: PhysiologyViewMetrics.spacing,
										trailing: PhysiologyViewMetrics.inset))
					.background(i % 2 != 0
								? RoundedRectangle(cornerRadius: 4).foregroundColor(.systemFill)
								: nil)
			}
		}
		.font(Font.system(PhysiologyViewMetrics.textStyle).monospacedDigit())
		.padding(PhysiologyViewMetrics.margin)
	}
}

#Preview {
	PhysiologyView(MHMockDataOffer.monster1.createPhysiology())
		.padding()
}
