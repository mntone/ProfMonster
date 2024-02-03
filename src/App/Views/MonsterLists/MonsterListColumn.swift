import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterListColumn: View {
#if os(macOS)
	@Environment(\.accessibilityReduceMotion)
	private var accessibilityReduceMotion
#endif

#if os(iOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selectedGameID: CoordinatorUtil.GameIDType?

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

#if os(iOS)
	@State
	private var isSearching: Bool = false

	@State
	private var topOffset: CGFloat = 0.0
#endif

	var body: some View {
		let items = viewModel.items
		let isHeaderShow = items.count > 1 || items.first?.type.isValidType == true
		List(items, id: \.id, selection: $selectedMonsterID) { group in
#if os(iOS)
			Section {
				ForEach(group.items) { item in
					MonsterListItem(viewModel: item.content)
				}
				.listRowInsets(EdgeInsets(top: 0.0,
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
					MonsterListItem(viewModel: item.content)
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
		.injectHorizontalLayoutMargin()
		.scrollDismissesKeyboard(.immediately)
#endif
#if os(macOS)
		.backport.listStyleInsetAlternatingRowBackgrounds()
		.animation(viewModel.disableAnimations || ProcessInfo.processInfo.isLowPowerModeEnabled || accessibilityReduceMotion ? nil : .default,
				   value: viewModel.items)
#endif
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				SortToolbarMenu(hasSizes: viewModel.hasSizes,
								sort: $viewModel.sort,
								groupOption: $viewModel.groupOption)
			}
		}
#if os(iOS)
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
#else
		.searchable(text: $viewModel.searchText, prompt: Text("Monster and Weakness"))
#endif
		.stateOverlay(viewModel.state, refresh: viewModel.refresh)
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
#if os(macOS)
		.navigationSubtitle(viewModel.state.isComplete
							? Text("\(viewModel.itemsCount) Monsters")
							: Text(verbatim: ""))
#endif
		.task(id: selectedGameID) {
			viewModel.set(id: selectedGameID)
		}
	}
}

#if os(iOS)

// List doesn't support selection on iPadOS 15.
// This is back-ported selection.

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use MonsterListColumn instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterListColumnBackport: View {
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selectedGameID: CoordinatorUtil.GameIDType?

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		MonsterList(viewModel: viewModel, rowInsets: .zero) { item in
			MonsterListItem(viewModel: item.content) { content in
				SelectableListRowBackport(tag: item.id, selection: $selectedMonsterID) {
					content.padding(EdgeInsets(top: 0.0,
											   leading: horizontalLayoutMargin - 10.0,
											   bottom: 0.0,
											   trailing: horizontalLayoutMargin))
				}
			}
		}
		.injectHorizontalLayoutMargin()
		.task(id: selectedGameID) {
			viewModel.set(id: selectedGameID)
		}
	}
}

#endif

@available(iOS 16.0, *)
#Preview("Default") {
	MonsterListColumn()
#if os(macOS)
		.frame(minWidth: 150, idealWidth: 200, maxWidth: 240)
#endif
}

#if os(iOS)

#Preview("Backport") {
	MonsterListColumnBackport()
}

#endif
