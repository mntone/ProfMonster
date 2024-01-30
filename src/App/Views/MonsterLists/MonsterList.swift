import SwiftUI

@available(macOS, unavailable)
struct MonsterList<ItemView: View>: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@ViewBuilder
	let content: (IdentifyHolder<GameItemViewModel>) -> ItemView

#if !os(watchOS)
	@State
	private var isSearching: Bool = false
#endif

	var body: some View {
		let items = viewModel.items
		let isHeaderShow = items.count > 1 || items.first?.type.isValidType == true
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
		.block { content in
			if #available(watchOS 10.2, *) {
				// The "searchable" is broken on watchOS 10.2.
				content
			} else {
				content.searchable(text: $viewModel.searchText, prompt: Text("Search"))
			}
		}
#else
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				SortToolbarMenu(hasSizes: viewModel.hasSizes,
								sort: $viewModel.sort,
								groupOption: $viewModel.groupOption)
			}
		}
		.backport.searchable(text: $viewModel.searchText,
							 isPresented: $isSearching,
							 prompt: Text("Monster and Weakness"))
		.background(
			Button("Search") {
				if !isSearching {
					isSearching = true
				}
			}
			.keyboardShortcut("F")
			.hidden()
		)
#endif
		.stateOverlay(viewModel.state)
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
	}
}

