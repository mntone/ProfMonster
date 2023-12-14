import SwiftUI

struct NavigationSplitViewHost: View {
	private let viewModel: HomeViewModel

	@State
	private var selectedGameID: String?

	@State
	private var gameViewModel: GameViewModel?

	@State
	private var selectedMonsterID: String?

	@Binding
	private var path: [MARoute]

	init(_ viewModel: HomeViewModel,
		 path: Binding<[MARoute]>) {
		self.viewModel = viewModel
		self._path = path
	}

	@available(iOS 16.0, macOS 13.0, *)
	private var host: some View {
		NavigationSplitView {
			Sidebar(viewModel: viewModel, selectedGameID: $selectedGameID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 140, ideal: 160, max: 200)
#endif
		} content: {
#if os(macOS)
			ZStack {
				Color(.monsterListBackground)

				if let gameViewModel {
					MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
				}
			}
			.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#else
			if let selectedGameID {
				let gameViewModel = GameViewModel(id: selectedGameID)!
				MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
			}
#endif
		} detail: {
			Group {
				if let selectedMonsterID,
				   let selectedGameID {
					let monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)!
					MonsterView(viewModel: monsterViewModel)
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
			Sidebar(viewModel: viewModel, selectedGameID: $selectedGameID)

#if os(macOS)
			ZStack {
				Color(.monsterListBackground)

				if let gameViewModel {
					MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
				}
			}
#else
			if let gameViewModel {
				MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
			} else {
				Color.clear
			}
#endif

			if let selectedMonsterID,
			   let selectedGameID {
				let monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)!
				MonsterView(viewModel: monsterViewModel)
			} else {
				Color(.monsterBackground)
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
		}.onChange(of: viewModel.items.first) { newValue in
			selectedGameID = newValue?.id
		}.onChange(of: selectedGameID) { newValue in
			selectedMonsterID = nil

			if let newValue {
				path = [.game(gameId: newValue)]
				gameViewModel = GameViewModel(id: newValue)!
			} else {
				path = []
				gameViewModel = nil
			}
		}.onChange(of: selectedMonsterID) { newValue in
			if let newValue {
				path = [path[0], .monster(gameId: selectedGameID!, monsterId: newValue)]
			} else {
				path = [path[0]]
			}
		}
		.task {
			loadPath()
		}
	}

	private func loadPath() {
		switch path.first {
		case let .game(gameID):
			selectedGameID = gameID

			guard path.count >= 2,
				  case let .monster(gameID2, monsterID) = path[1] else {
				return
			}
			precondition(gameID == gameID2) // Assume X == Y for MARoute.game(X) and MARoute.monster(Y, _)
			selectedMonsterID = monsterID

		default:
			// Select the first item when new scene.
			selectedGameID = viewModel.items.first?.id
		}
	}
}
