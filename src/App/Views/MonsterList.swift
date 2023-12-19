import MonsterAnalyzerCore
import SwiftUI

private func sortToolbarItem(selection: Binding<Sort>) -> some ToolbarContent {
	ToolbarItem(placement: .primaryAction) {
		Menu("Sort", systemImage: "arrow.up.arrow.down.circle") {
			Picker(selection: selection) {
				Text("In Game").tag(Sort.inGame)
				Text("Name").tag(Sort.name)
			} label: {
				EmptyView()
			}
			.pickerStyle(.inline)
		}
	}
}

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
			sortToolbarItem(selection: $viewModel.sort)
		}
#if os(macOS)
		.alternatingRowBackgroundsBackport(enable: true)
#else
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.name)
#endif
		.onChangeBackport(of: viewModel, initial: true) { _, newValue in
			newValue.fetchData()
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use MonsterList instead")
struct MonsterListBackport: View {
	@Environment(\.isFocused)
	private var isFocused

	@ObservedObject
	private(set) var viewModel: GameViewModel

	@Binding
	private(set) var selectedMonsterID: String?

	var body: some View {
		StateView(state: viewModel.state) {
			List(viewModel.items, id: \.id) { item in
				SelectableListRowBackport(tag: item.id, selection: $selectedMonsterID) {
					MonsterListItem(viewModel: item)
				}
			}
			.searchable(text: $viewModel.searchText, prompt: Text("Monster and Weakness"))
		}
		.toolbar {
			sortToolbarItem(selection: $viewModel.sort)
		}
		.navigationBarTitleDisplayMode(.inline)
		.navigationTitle(viewModel.name)
		.onChangeBackport(of: viewModel, initial: true) { _, newValue in
			newValue.fetchData()
		}
	}
}

#endif

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
}
