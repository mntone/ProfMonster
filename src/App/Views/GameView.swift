import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
struct GameView: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			NavigationLink(value: MARoute.monster(gameID: item.gameID, monsterID: item.id)) {
				MonsterListItem(viewModel: item)
			}
		}
#if os(iOS)
		.listStyle(.plain)
		.scrollDismissesKeyboard(.immediately)
#endif
		.navigationTitle(Text(verbatim: viewModel.name))
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText,
											isLoading: viewModel.state.isLoading))
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use GameView instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use GameView instead")
struct GameViewBackport: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@Binding
	var selectedMonsterID: String?

	var body: some View {
		ScrollViewReader { reader in
			List(viewModel.state.data ?? []) { item in
				NavigationLink(tag: item.id, selection: $selectedMonsterID) {
					LazyView {
						let monsterViewModel = MonsterViewModel(id: item.id, for: viewModel.id)!
						MonsterView(viewModel: monsterViewModel)
					}
				} label: {
					MonsterListItem(viewModel: item)
				}
			}
#if os(iOS)
			.listStyle(.plain)
			.backport.scrollDismissesKeyboard(.immediately)
#endif
			.onAppear {
				if let selectedMonsterID {
					reader.scrollTo(selectedMonsterID)
				}
			}
		}
		.navigationTitle(Text(verbatim: viewModel.name))
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText,
											isLoading: viewModel.state.isLoading))
	}
}

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	if #available(iOS 16.0, watchOS 9.0, *) {
		return GameView(viewModel: viewModel)
	} else {
		return GameViewBackport(viewModel: viewModel, selectedMonsterID: .constant(nil))
	}
}

#endif
