import MonsterAnalyzerCore
import SwiftUI

struct MonsterList: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@Binding
	private(set) var selectedMonsterID: String?

	var body: some View {
		List(viewModel.state.data ?? [], id: \.id, selection: $selectedMonsterID) { item in
			MonsterListItem(viewModel: item)
		}
#if os(macOS)
		.animation(.default, value: viewModel.state.data)
#endif
		.navigationTitle(Text(verbatim: viewModel.name))
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText,
											isLoading: viewModel.state.isLoading))
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
		List(viewModel.state.data ?? [], id: \.id) { item in
			SelectableListRowBackport(tag: item.id, selection: $selectedMonsterID) {
				MonsterListItem(viewModel: item)
			}
		}
		.navigationTitle(Text(verbatim: viewModel.name))
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText,
											isLoading: viewModel.state.isLoading))
	}
}

#endif

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
}
