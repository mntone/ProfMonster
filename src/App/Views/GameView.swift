import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

#if !os(watchOS)

private func sortToolbarItem(selection: Binding<Sort>) -> some ToolbarContent {
	ToolbarItem(placement: .primaryAction) {
		Menu {
			Picker(selection: selection) {
				Text("game.sort[ingame]").tag(Sort.inGame)
				Text("game.sort[name]").tag(Sort.name)
			} label: {
				EmptyView()
			}
		} label: {
			Label("game.sort",
				  systemImage: "arrow.up.arrow.down.circle")
		}
	}
}

#endif

@available(iOS 16.0, watchOS 9.0, *)
struct GameView: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	var body: some View {
		StateView(state: viewModel.state) {
			List(viewModel.items) { item in
				NavigationLink(value: MARoute.monster(gameId: item.gameID, monsterId: item.id)) {
					MonsterListItem(viewModel: item)
				}
			}
#if os(watchOS)
			.searchable(text: $viewModel.searchText, prompt: Text("game.search[short]"))
#else
			.searchable(text: $viewModel.searchText, prompt: Text("game.search[long]"))
			.listStyle(.plain)
#endif
		}
#if !os(watchOS)
		.toolbar {
			sortToolbarItem(selection: $viewModel.sort)
		}
#endif
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
		.task {
			viewModel.fetchData()
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use GameView instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use GameView instead")
struct GameViewBackport: View {
	@ObservedObject
	private(set) var viewModel: GameViewModel

	@Binding
	private(set) var selectedMonsterID: String?

	var body: some View {
		StateView(state: viewModel.state) {
			List(viewModel.items) { item in
				NavigationLink(tag: item.id, selection: $selectedMonsterID) {
					LazyView {
						let monsterViewModel = MonsterViewModel(id: item.id, for: viewModel.id)!
						MonsterView(viewModel: monsterViewModel)
					}
				} label: {
					MonsterListItem(viewModel: item)
				}
			}
#if os(watchOS)
			.searchable(text: $viewModel.searchText, prompt: Text("game.search[short]"))
#else
			.searchable(text: $viewModel.searchText, prompt: Text("game.search[long]"))
			.listStyle(.plain)
#endif
		}
#if !os(watchOS)
		.toolbar {
			sortToolbarItem(selection: $viewModel.sort)
		}
#endif
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
		.task {
			viewModel.fetchData()
		}
	}
}

#Preview {
	let viewModel = GameViewModel(id: "mockgame")!
	if #available(iOS 16.0, watchOS 9.0, *) {
		return GameView(viewModel: viewModel)
	} else {
		return GameViewBackport(viewModel: viewModel, selectedMonsterID: .constant(nil))
	}
}

#endif
