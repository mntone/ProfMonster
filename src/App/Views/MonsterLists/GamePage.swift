#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct GamePage: View {
	let id: String

	@StateObject
	private var viewModel = GameViewModel()

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterListNavigatableItem(viewModel: item)
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
	let id: String

	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selection: CoordinatorUtil.MonsterIDType?

	@StateObject
	private var viewModel = GameViewModel()

	@State
	private var restoreMonsterID: CoordinatorUtil.MonsterIDType?

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterListNavigatableItemBackport(viewModel: item,
											   selection: $selection)
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
			viewModel.set(id: id)

			if let selection {
				restoreMonsterID = selection
			}
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
