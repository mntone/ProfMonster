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
			.searchable(text: $viewModel.searchText, prompt: Text("Monster and Weakness"))
#if os(macOS)
			.animation(.default, value: viewModel.items)
			.listRowBackground(Color.clear)
#endif
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Menu("Sort", systemImage: "arrow.up.arrow.down.circle") {
					Picker(selection: $viewModel.sort) {
						Text("In Game").tag(Sort.inGame)
						Text("Name").tag(Sort.name)
					} label: {
						EmptyView()
					}
					.pickerStyle(.inline)
				}
			}
		}
		.onChangeBackport(of: viewModel, initial: true) { _, viewModel in
			viewModel.fetchData()
		}
#if os(macOS)
		.alternatingRowBackgroundsBackport(enable: true)
#else
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.name)
#endif
	}
}

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
}
