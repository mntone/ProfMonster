import MonsterAnalyzerCore
import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterList: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	let selection: Binding<GameViewModel.ID?>

	@ViewBuilder
	private var list: some View {
		let items = viewModel.state.data ?? []
		if items.count > 1 || items.first?.type.isType == true {
			List(items, id: \.id, selection: selection) { group in
				Section(group.label) {
					ForEach(group.items) { item in
						MonsterListItem(viewModel: item)
					}
				}
			}
		} else {
			List(items.first?.items ?? [], id: \.id, selection: selection) { item in
				MonsterListItem(viewModel: item)
			}
		}
	}

	var body: some View {
		list
#if os(macOS)
			.backport.alternatingRowBackgrounds()
			.animation(.default, value: viewModel.state.data)
#endif
#if os(iOS)
			.scrollDismissesKeyboard(.immediately)
#endif
			.navigationTitle(Text(verbatim: viewModel.name))
			.modifier(SharedMonsterListModifier(state: viewModel.state,
												sort: $viewModel.sort,
												searchText: $viewModel.searchText))
	}
}

@available(iOS 16.0, *)
@available(watchOS, unavailable)
#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return MonsterList(viewModel: viewModel, selection: .constant(nil))
}
