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
		let items = viewModel.state.data ?? []
		if items.count > 1 || items.first?.type.isType == true {
			List(items) { group in
				Section {
					ForEach(group.items) { item in
						content(item.content)
					}
				} header: {
					Text(verbatim: group.label)
				}
			}
		} else {
			List(items.first?.items ?? []) { item in
				content(item.content)
			}
		}
	}

	var body: some View {
		list
#if os(iOS)
			.listStyle(.plain)
			.backport.scrollDismissesKeyboard(.immediately)
#endif
			.navigationTitle(viewModel.name.map(Text.init(verbatim:)) ?? Text("Unknown"))
			.modifier(StatusOverlayModifier(state: viewModel.state))
			.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
												searchText: $viewModel.searchText))
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview {
	let viewModel = GameViewModel()
	viewModel.set(id: "mockgame")
	return NavigationStack {
		GamePage(viewModel: viewModel) { item in
			MonsterListNavigatableItem(viewModel: item)
		}
	}
}

#endif
