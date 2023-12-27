import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct GamePage<ItemView: View>: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@ViewBuilder
	let content: (GameItemViewModel) -> ItemView

	@ViewBuilder
	private var list: some View {
#if os(watchOS)
		List(viewModel.state.data ?? []) { item in
			content(item)
		}
#else
		let items = viewModel.state.data ?? []
		if items.count > 1 || items.first?.type.isType == true {
			List(items) { group in
				Section(group.label) {
					ForEach(group.items) { item in
						content(item)
					}
				}
			}
		} else {
			List(items.first?.items ?? []) { item in
				content(item)
			}
		}
#endif
	}

	var body: some View {
		list
#if os(iOS)
			.listStyle(.plain)
			.backport.scrollDismissesKeyboard(.immediately)
#endif
			.navigationTitle(Text(verbatim: viewModel.name))
			.modifier(SharedMonsterListModifier(state: viewModel.state,
												sort: $viewModel.sort,
												searchText: $viewModel.searchText))
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	return NavigationStack {
		GamePage(viewModel: viewModel) { item in
			MonsterListNavigatableItem(viewModel: item)
		}
	}
}

#endif
