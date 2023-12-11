import SwiftUI

struct NavigationSplitViewHost: View {
	private let homeViewModel: HomeViewModel

	@State
	private var gameViewModel: GameViewModel?

	@State
	private var monsterViewModel: MonsterViewModel?

	@Binding
	private var path: [MARoute]

	init(_ viewModel: HomeViewModel,
		 path: Binding<[MARoute]>) {
		self.homeViewModel = viewModel
		self._path = path
	}

	var body: some View {
		Group {
			if #available(iOS 16.0, macOS 13.0, *) {
				NavigationSplitView {
					RootView(homeViewModel, selected: $gameViewModel)
#if os(macOS)
						.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#endif
				} content: {
					Group {
						if let gameViewModel {
							MonsterList(gameViewModel, selected: $monsterViewModel)
						}
					}
#if os(macOS)
					.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#endif
				} detail: {
					Group {
						if let monsterViewModel {
							MonsterView(monsterViewModel)
						}
					}
#if os(macOS)
					.navigationSplitViewColumnWidth(min: 180, ideal: 375)
#endif
				}
			} else {
				NavigationView {
					RootView(homeViewModel, selected: $gameViewModel)

					if let gameViewModel {
						MonsterList(gameViewModel, selected: $monsterViewModel)
					} else {
						EmptyView()
					}

					if let monsterViewModel {
						MonsterView(monsterViewModel)
					} else {
						EmptyView()
					}
				}
			}
		}.onChange(of: gameViewModel) { newValue in
			monsterViewModel = nil

			if let newValue {
				path = [.game(gameId: newValue.id)]
			} else {
				path = []
			}
		}.onChange(of: monsterViewModel) { newValue in
			if let newValue {
				path = [path[0], .monster(gameId: gameViewModel!.id, monsterId: newValue.id)]
			} else if let gameViewModel {
				path = [path[0]]
			}
		}.task {
			loadPath()
		}
	}

	private func loadPath() {
		switch path.first {
		case let .game(gameId):
			let gameViewModel = homeViewModel.getOrCreate(id: gameId)
			self.gameViewModel = gameViewModel

			guard path.count >= 2 else {
				return
			}

			if case let .monster(_, monsterPath) = path[1] {
				monsterViewModel = gameViewModel.getOrCreate(id: monsterPath)
			}

		default:
			// Select the first game when new scene.
			self.gameViewModel = homeViewModel.games.first
		}
	}
}
