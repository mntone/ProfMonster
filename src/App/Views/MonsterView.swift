import MonsterAnalyzerCore
import SwiftUI

struct MonsterView: View {
	@ObservedObject
	private var viewModel: MonsterViewModel

	init(_ viewModel: MonsterViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		ZStack {
			switch viewModel.state {
			case .ready:
				EmptyView()
			case .loading:
				ProgressView()
			case let .complete(monster):
				Form {
					Section {
						FixedWidthWeaknessView(monster.createWeakness())
					} header: {
						Text("header.weakness")
					}

					Section {
						PhysiologyScrollableView(monster.createPhysiology())
							.listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
					} header: {
						Text("header.physiology")
					}
				}
#if os(macOS)
				.listStyle(.plain)
#elseif os(iOS)
				.listRowBackground(Color.clear)
#endif
			case let .failure(_, reason):
				Text(verbatim: String(localized: reason.localizationValue))
			}
		}
#if os(iOS)
		.background(Color.systemGroupedBackground, ignoresSafeAreaEdges: .all)
#endif
		.navigationTitle(viewModel.name ?? viewModel.id)
		.task {
			viewModel.loadIfNeeded()
		}
    }
}

#Preview {
	MonsterView(MonsterViewModel("gulu_qoo", of: "mockgame"))
}
