#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct GamePage: View {
	let id: String

	@StateObject
	var viewModel = GameViewModel()

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

	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	var viewModel = GameViewModel()

	@State
	var restoreMonsterID: CoordinatorViewModel.MonsterIDType?

	var body: some View {
		MonsterList(viewModel: viewModel) { item in
			MonsterListNavigatableItemBackport(viewModel: item,
											   selection: $coord.selectedMonsterID)
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

			if let selection = coord.selectedMonsterID {
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
