import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterListColumn: View {
#if os(macOS)
	@Environment(\.accessibilityReduceMotion)
	private var accessibilityReduceMotion
#endif

	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selectedGameID: CoordinatorUtil.GameIDType?

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		let items = viewModel.items
		let isHeaderShow = items.count > 1 || items.first?.type.isType == true
		List(items, id: \.id, selection: $selectedMonsterID) { group in
			Section {
				ForEach(group.items) { item in
					MonsterListItem(viewModel: item.content)
				}
			} header: {
				if isHeaderShow {
					Text(group.label)
				}
			}
		}
#if os(iOS)
		.listStyle(.plain)
		.scrollDismissesKeyboard(.immediately)
#endif
#if os(macOS)
		.backport.listStyleInsetAlternatingRowBackgrounds()
		.animation(ProcessInfo.processInfo.isLowPowerModeEnabled || accessibilityReduceMotion ? nil : .default,
				   value: viewModel.items)
#endif
		.stateOverlay(viewModel.state)
		.navigationTitle(viewModel.name)
#if os(macOS)
		.navigationSubtitle(viewModel.state.isComplete
							? Text("\(viewModel.itemsCount) Monsters")
							: Text(verbatim: ""))
#endif
		.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
											searchText: $viewModel.searchText))
		.task(id: selectedGameID) {
			viewModel.set(id: selectedGameID)
		}
	}
}

#if os(iOS)

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use MonsterListColumn instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterListColumnBackport: View {
	@SceneStorage(CoordinatorUtil.GAME_ID_STORAGE_NAME)
	private var selectedGameID: CoordinatorUtil.GameIDType?

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterSelectableListItem(viewModel: item,
									  selection: $selectedMonsterID)
		}
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
