import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct NavigationSplitViewHost: View {
	let viewModel: HomeViewModel

	@Binding
	var selectedGameID: String?

	@Binding
	var selectedMonsterID: String?

#if os(iOS)
	@State
	private var screenWidth: CGFloat = 0
#endif

	@State
	private var gameViewModel: GameViewModel? = nil

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationSplitView {
			Sidebar(viewModel: viewModel, selectedGameID: $selectedGameID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 140, ideal: 160, max: 200)
#endif
		} content: {
#if os(macOS)
			Group {
				if let gameViewModel {
					MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
				} else {
					Color.monsterListBackground.ignoresSafeArea()
				}
			}
			.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#else
			if let gameViewModel {
				MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
			}
#endif
		} detail: {
#if os(iOS)
			if let monsterViewModel {
				MonsterView(viewModel: monsterViewModel)
			} else {
				Color.monsterBackground.ignoresSafeArea()
			}
#else
			Group {
				if let monsterViewModel {
					MonsterView(viewModel: monsterViewModel)
				}
			}
			.navigationSplitViewColumnWidth(min: 180, ideal: 375)
#endif
		}
#if os(iOS)
		.background {
			GeometryReader { proxy in
				Color.clear.onChangeBackport(of: proxy.size.width, initial: true) { _, newValue in
					screenWidth = newValue
				}
			}
		}
		.if(screenWidth >= 1000) { s in
			s.navigationSplitViewStyle(.balanced)
		} else: { s in
			s.navigationSplitViewStyle(.prominentDetail)
		}
#endif
		.onAppear {
			if let selectedGameID {
				gameViewModel = GameViewModel(id: selectedGameID)!

				if let selectedMonsterID {
					monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)
				}
			} else {
				// Select the first item when new scene.
				selectedGameID = viewModel.state.data?.first?.id
			}
		}
		.onReceive(viewModel.$state) { newValue in
			selectedMonsterID = nil
			if let items = newValue.data {
				let selectedGameID = items.first?.id
				self.selectedGameID = selectedGameID
				updateGameViewModel(of: selectedGameID)
			} else {
				selectedGameID = nil
			}
		}
		.onChange(of: selectedGameID, perform: updateGameViewModel)
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
	}

	private func updateGameViewModel(of id: String?) {
		if let id {
			gameViewModel = GameViewModel(id: id)
		} else {
			gameViewModel = nil
		}
	}

	private func updateMonsterViewModel(of id: String?) {
		if let selectedGameID,
		   let id {
			monsterViewModel = MonsterViewModel(id: id, for: selectedGameID)
		} else {
			monsterViewModel = nil
		}
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use NavigationSplitViewHost instead")
@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use NavigationSplitViewHost instead")
struct NavigationSplitViewHostBackport: View {
	let viewModel: HomeViewModel

	@Binding
	var selectedGameID: String?

	@Binding
	var selectedMonsterID: String?

	@State
	private var gameViewModel: GameViewModel? = nil

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationView {
#if os(macOS)
			Sidebar(viewModel: viewModel, selectedGameID: $selectedGameID)

			if let monsterViewModel {
				MonsterView(viewModel: monsterViewModel)
			} else {
				Color.monsterBackground.ignoresSafeArea()
			}
#else
			SidebarBackport(viewModel: viewModel, selectedGameID: $selectedGameID)

			if let gameViewModel {
				MonsterListBackport(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
			} else {
				Color.clear
			}
#endif

			if let monsterViewModel {
				MonsterView(viewModel: monsterViewModel)
			} else {
				Color.monsterBackground.ignoresSafeArea()
			}
		}
		.navigationViewStyle(.columns)
		.onAppear {
			if let selectedGameID {
				gameViewModel = GameViewModel(id: selectedGameID)!

				if let selectedMonsterID {
					monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)
				}
			} else {
				// Select the first item when new scene.
				selectedGameID = viewModel.state.data?.first?.id
			}
		}
		.onReceive(viewModel.$state) { newValue in
			selectedMonsterID = nil
			if let items = newValue.data {
				let selectedGameID = items.first?.id
				self.selectedGameID = selectedGameID
				updateGameViewModel(of: selectedGameID)
			} else {
				selectedGameID = nil
			}
		}
		.onChange(of: selectedGameID, perform: updateGameViewModel)
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
	}

	private func updateGameViewModel(of id: String?) {
		if let id {
			gameViewModel = GameViewModel(id: id)
		} else {
			gameViewModel = nil
		}
	}

	private func updateMonsterViewModel(of id: String?) {
		if let selectedGameID,
		   let id {
			monsterViewModel = MonsterViewModel(id: id, for: selectedGameID)
		} else {
			monsterViewModel = nil
		}
	}
}
