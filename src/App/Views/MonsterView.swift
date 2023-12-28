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
		StateView(state: viewModel.state, background: background) { data in
			Form {
				if viewModel.elementDisplay != .none {
					Section("Weakness") {
						FixedWidthWeaknessView(viewModel: data.weakness,
											   displayMode: viewModel.elementDisplay)
					}
				}

				Section("Physiology") {
					let headerHidden = data.physiologies.sections.count <= 1
					ForEach(data.physiologies.sections) { section in
#if os(macOS)
						PhysiologyView(viewModel: section, headerHidden: headerHidden)
#else
						if !headerHidden {
							VStack(alignment: .leading, spacing: 0) {
								Text(verbatim: section.header)
									.font(.system(.subheadline).weight(.medium))
									.padding(.horizontal)
								PhysiologyScrollableView(viewModel: section)
							}
							.listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
						} else {
							PhysiologyScrollableView(viewModel: section)
								.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
						}
#endif
					}
				}
			}
			.block {
				if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
					$0.formStyle(.grouped)
				} else {
					$0
				}
			}
			.headerProminence(.increased)
		}
		.navigationTitle(Text(verbatim: viewModel.name))
	}
}

#Preview {
	let viewModel = MonsterViewModel(id: "gulu_qoo", for: "mockgame")!
	return MonsterView(viewModel: viewModel)
}
