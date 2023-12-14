import MonsterAnalyzerCore
import SwiftUI

struct MonsterView: View {
	@ObservedObject
	private(set) var viewModel: MonsterViewModel

	var body: some View {
#if os(iOS)
		let background: Color? = Color.systemGroupedBackground
#else
		let background: Color? = nil
#endif
		StateView(state: viewModel.state, background: background) {
			Form {
				Section {
					FixedWidthWeaknessView(viewModel.data.createWeakness())
				} header: {
					Text("header.weakness")
				}

				Section {
					PhysiologyScrollableView(viewModel.data.createPhysiology())
						.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
				} header: {
					Text("header.physiology")
				}
			}
			.headerProminence(.increased)
#if os(iOS)
			.listRowBackground(Color.clear)
#endif
		}
		.navigationTitle(viewModel.name)
		.onChangeBackport(of: viewModel, initial: true) { _, viewModel in
			viewModel.fetchData()
		}
    }
}

#Preview {
	let viewModel = MonsterViewModel(id: "gulu_qoo", for: "mockgame")!
	return MonsterView(viewModel: viewModel)
}
