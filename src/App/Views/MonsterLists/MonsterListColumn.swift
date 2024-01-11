import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterListColumn: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = GameViewModel()

#if os(macOS)
	@Environment(\.accessibilityReduceMotion)
	private var accessibilityReduceMotion
#endif

	@ViewBuilder
	private var list: some View {
		let items = viewModel.items
#if os(macOS)
		if items.count > 1 || items.first?.type.isType == true {
			List(items, id: \.id, selection: $coord.selectedMonsterID) { group in
				Section(group.label) {
					ForEach(group.items) { item in
						MonsterListItem(viewModel: item.content)
					}
				}
			}
		} else {
			List(items.first?.items ?? [], id: \.id, selection: $coord.selectedMonsterID) { item in
				MonsterListItem(viewModel: item.content)
			}
		}
#else
		List(items, id: \.id, selection: $coord.selectedMonsterID) { group in
			Section {
				ForEach(group.items) { item in
					MonsterListItem(viewModel: item.content)
				}
			} header: {
				if items.count > 1 {
					Text(group.label)
				}
			}
		}
#endif
	}

	var body: some View {
		list
#if os(macOS)
			.backport.alternatingRowBackgrounds()
			.animation(ProcessInfo.processInfo.isLowPowerModeEnabled || accessibilityReduceMotion ? nil : .default,
					   value: viewModel.items)
#endif
#if os(iOS)
			.scrollDismissesKeyboard(.immediately)
#endif
			.stateOverlay(viewModel.state)
			.navigationTitle(viewModel.name.map(Text.init) ?? Text("Unknown"))
#if os(macOS)
			.navigationSubtitle(viewModel.state.isComplete
								? Text("\(viewModel.itemsCount) Monsters")
								: Text(verbatim: ""))
#endif
			.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
												searchText: $viewModel.searchText))
			.task {
				viewModel.set(id: coord.selectedGameID)
			}
			.onChangeBackport(of: coord.selectedGameID) { _, newValue in
				viewModel.set(id: newValue)
			}
	}
}

#if os(iOS)

@available(watchOS, unavailable)
struct MonsterListColumnBackport: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterSelectableListItem(viewModel: item,
									  selection: $coord.selectedMonsterID)
		}
		.task {
			viewModel.set(id: coord.selectedGameID)
		}
		.onChangeBackport(of: coord.selectedGameID) { _, newValue in
			viewModel.set(id: newValue)
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
		.environmentObject(CoordinatorViewModel(gameID: "mockgame"))
}

#if os(iOS)

#Preview("Backport") {
	MonsterListColumnBackport()
		.environmentObject(CoordinatorViewModel(gameID: "mockgame"))
}

#endif
