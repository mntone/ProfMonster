import MonsterAnalyzerCore
import SwiftUI

@available(iOS 16.0, *)
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
#if os(iOS)
		.scrollDismissesKeyboard(.immediately)
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
#if os(iOS)
		.backport.scrollDismissesKeyboard(.immediately)
#endif
		.navigationTitle(Text(verbatim: viewModel.name))
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText,
											isLoading: viewModel.state.isLoading))
	}
}

#endif

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
#if os(macOS)
	return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
#else
	if #available(iOS 16.0, *) {
		return MonsterList(viewModel: viewModel, selectedMonsterID: .constant(nil))
	} else {
		return MonsterListBackport(viewModel: viewModel, selectedMonsterID: .constant(nil))
	}
#endif
}
