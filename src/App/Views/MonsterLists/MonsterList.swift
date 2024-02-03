import SwiftUI

@available(macOS, unavailable)
struct MonsterList<ItemView: View>: View {
#if os(iOS)
	let rowInsets: EdgeInsets?

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	@ObservedObject
	private(set) var viewModel: GameViewModel

	@ViewBuilder
	let content: (IdentifyHolder<GameItemViewModel>) -> ItemView

#if !os(watchOS)
	@State
	private var isSearching: Bool = false
#endif

#if os(iOS)
	@State
	private var topOffset: CGFloat = 0.0

	init(viewModel: GameViewModel,
		 rowInsets: EdgeInsets? = nil,
		 content: @escaping (IdentifyHolder<GameItemViewModel>) -> ItemView) {
		self.rowInsets = rowInsets
		self.viewModel = viewModel
		self.content = content
	}
#else
	init(viewModel: GameViewModel,
		 content: @escaping (IdentifyHolder<GameItemViewModel>) -> ItemView) {
		self.viewModel = viewModel
		self.content = content
	}
#endif

	var body: some View {
		let items = viewModel.items
		let isHeaderShow = items.count > 1 || items.first?.type.isValidType == true
		List(items) { group in
#if os(iOS)
			Section {
				TopSeparatorRemover {
					ForEach(group.items) { item in
						content(item)
					}
				}
				.listRowInsets(rowInsets ?? EdgeInsets(top: 0.0,
													   leading: horizontalLayoutMargin - 10.0,
													   bottom: 0.0,
													   trailing: horizontalLayoutMargin))
			} header: {
				if isHeaderShow {
					MobileMonsterListHeader(text: group.label, topOffset: topOffset)
				}
			}
#else
			Section {
				ForEach(group.items) { item in
					content(item)
				}
			} header: {
				if isHeaderShow {
					Text(group.label)
				}
			}
#endif
		}
#if os(iOS)
		.listStyle(.plain)
		.coordinateSpace(name: MobileMonsterListHeader.listCoordinateSpace)
		.background(alignment: .topLeading) {
			YObserver { y in
				topOffset = y
			}
		}
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
		.stateOverlay(viewModel.state, refresh: viewModel.refresh)
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
	}
}

