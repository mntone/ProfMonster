#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct GamePage: View {
	let id: CoordinatorUtil.GameIDType

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterListItem(viewModel: item.content) { content in
				NavigationLink(value: MARoute.monster(id: item.content.id)) {
					content
				}
			}
		}
		.task {
			viewModel.set(id: id)
		}
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use GamePage instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 8.0, deprecated: 9.0, message: "Use GamePage instead")
struct GamePageBackport: View {
	let id: CoordinatorUtil.GameIDType

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selection: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

	@State
	private var restoreMonsterID: CoordinatorUtil.MonsterIDType?

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterListItem(viewModel: item.content) { content in
				NavigationLink(tag: item.id, selection: $selection) {
					MonsterPage(id: item.content.id)
				} label: {
					content
				}
			}
		}
		.background {
			if let restoreMonsterID {
				NavigationLink(destination: MonsterPage(id: restoreMonsterID), isActive: isActive) {
					Never?.none
				}
				.tint(.clear)
			}
		}
		.task {
			if let selection {
				restoreMonsterID = selection
				self.selection = nil
			}

			viewModel.set(id: id)
		}
	}

	private var isActive: Binding<Bool> {
		Binding {
			restoreMonsterID != nil
		} set: { newValue in
			if !newValue {
				restoreMonsterID = nil
			}
		}
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview("Default") {
	NavigationStack {
		GamePage(id: "mockgame")
	}
}

@available(macOS, unavailable)
#Preview("Backport") {
	NavigationView {
		GamePageBackport(id: "mockgame")
	}
	.navigationViewStyle(.stack)
}

#endif
