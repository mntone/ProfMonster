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
	
	@available(iOS 16.0, macOS 13.0, *)
	private var host: some View {
		NavigationSplitView {
			RootView(homeViewModel, selected: $gameViewModel)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#endif
		} content: {
#if os(macOS)
			Group {
				if let gameViewModel {
					MonsterList(gameViewModel, selected: $monsterViewModel)
				} else {
					Color(.monsterListBackground)
				}
			}
			.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#else
			if let gameViewModel {
				MonsterList(gameViewModel, selected: $monsterViewModel)
			}
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
	}

	@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use NavigationSplitViewHost.host instead")
	@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use NavigationSplitViewHost.host instead")
	private var hostBackport: some View {
		NavigationView {
			RootView(homeViewModel, selected: $gameViewModel)
			
			if let gameViewModel {
				MonsterList(gameViewModel, selected: $monsterViewModel)
			} else {
#if os(macOS)
				Color(.monsterListBackground)
#else
				EmptyView()
#endif
			}
			
			if let monsterViewModel {
				MonsterView(monsterViewModel)
			} else {
				EmptyView()
			}
		}
		.navigationViewStyle(.columns)
	}

	var body: some View {
		Group {
			if #available(iOS 16.0, macOS 13.0, *) {
				host
			} else {
				hostBackport
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
			} else if gameViewModel != nil {
				path = [path[0]]
			} else {
				path = []
			}
		}
		.task {
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
