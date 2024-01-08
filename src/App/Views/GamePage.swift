import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct GamePage<ItemView: View>: View {
	@StateObject
	var viewModel = GameViewModel()

	let id: String?

	@ViewBuilder
	let content: (IdentifyHolder<GameItemViewModel>) -> ItemView

	@ViewBuilder
	private var list: some View {
		let items = viewModel.items
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
	}

	var body: some View {
		list
#if os(iOS)
			.listStyle(.plain)
			.backport.scrollDismissesKeyboard(.immediately)
#endif
			.navigationTitle(viewModel.name.map(Text.init) ?? Text("Unknown"))
			.modifier(StatusOverlayModifier(state: viewModel.state))
			.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
												searchText: $viewModel.searchText))
			.onChangeBackport(of: id, initial: true) { _, newValue in
				viewModel.set(id: newValue)
			}
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview {
	NavigationStack {
		GamePage(id: "mockgame") { item in
			MonsterListNavigatableItem(viewModel: item)
		}
	}
}

#endif
