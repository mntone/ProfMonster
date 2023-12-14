import MonsterAnalyzerCore
import SwiftUI

struct MonsterList: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@Binding
	private(set) var selectedMonsterID: String?

	var body: some View {
		StateView(state: viewModel.state) {
			List(viewModel.items, id: \.id, selection: $selectedMonsterID) { item in
				MonsterListItem(viewModel: item)
			}
			.searchable(text: $viewModel.searchText, prompt: Text("game.search[long]"))
#if os(macOS)
			.animation(.default, value: viewModel.items)
			.listRowBackground(Color.clear)
#endif
		}
		.onChangeBackport(of: viewModel, initial: true) { _, viewModel in
			viewModel.fetchData()
		}
#if os(macOS)
		.alternatingRowBackgroundsBackport(enable: true)
#else
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
	}
}

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
}
