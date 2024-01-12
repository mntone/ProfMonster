#if !os(macOS)

import SwiftUI

@available(macOS, unavailable)
struct MonsterList<ItemView: View>: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@ViewBuilder
	let content: (IdentifyHolder<GameItemViewModel>) -> ItemView

	var body: some View {
		let items = viewModel.items
		let isHeaderShow = items.count > 1 || items.first?.type.isType == true
		List(items) { group in
			Section {
				ForEach(group.items) { item in
					content(item)
				}
			} header: {
				if isHeaderShow {
					Text(group.label)
				}
			}
		}
#if os(iOS)
		.listStyle(.plain)
		.backport.scrollDismissesKeyboard(.immediately)
#endif
#if os(watchOS)
		.modifier(SharedMonsterListModifier(searchText: $viewModel.searchText))
#else
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText))
#endif
		.stateOverlay(viewModel.state)
		.navigationTitle(viewModel.name.map(Text.init) ?? Text("Unknown"))
	}
}

#endif
