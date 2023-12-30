import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct MonsterListNavigatableItem: View {
	let viewModel: GameItemViewModel

	var body: some View {
		NavigationLink(value: MARoute.monster(gameID: viewModel.gameID, monsterID: viewModel.id)) {
			MonsterListItem(viewModel: viewModel)
		}
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use MonsterListNavigatableItem instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use MonsterListNavigatableItem instead")
struct MonsterListNavigatableItemBackport: View {
	let viewModel: GameItemViewModel
	let selection: Binding<GameItemViewModel.ID?>

	var body: some View {
		NavigationLink(tag: viewModel.id, selection: selection) {
			LazyView {
				let monsterViewModel = MonsterViewModel(id: viewModel.id, for: viewModel.gameID)!
				MonsterView(viewModel: monsterViewModel)
			}
		} label: {
			MonsterListItem(viewModel: viewModel)
		}
	}
}

#if os(iOS)

// List doesn't support selection on iPadOS 15.
// This is back-ported selection.

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use MonsterList instead")
@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MonsterSelectableListItem: View {
	let viewModel: GameItemViewModel
	let selection: Binding<GameItemViewModel.ID?>

	var body: some View {
		SelectableListRowBackport(tag: viewModel.id, selection: selection) {
			MonsterListItem(viewModel: viewModel)
		}
	}
}

#endif

#if DEBUG || targetEnvironment(simulator)
@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview {
	NavigationStack {
		let viewModel = GameItemViewModel(id: "gulu_qoo", gameID: "mockgame")!
		List {
			MonsterListNavigatableItem(viewModel: viewModel)
			MonsterListNavigatableItem(viewModel: viewModel)
			MonsterListNavigatableItem(viewModel: viewModel)
			MonsterListNavigatableItem(viewModel: viewModel)
		}
	}
}
#endif

#endif
