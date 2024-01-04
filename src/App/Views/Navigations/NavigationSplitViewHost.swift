import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
struct NavigationSplitViewHost: View {
	let viewModel: HomeViewModel

	@Binding
	var selectedGameID: HomeItemViewModel.ID?

	@Binding
	var selectedMonsterID: MonsterViewModel.ID?

#if os(iOS)
	@State
	private var screenWidth: CGFloat = 0
#endif

	@State
	private var gameViewModel = GameViewModel()

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationSplitView {
			Sidebar(viewModel: viewModel, selection: $selectedGameID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 120, ideal: 160, max: 200)
#endif
		} content: {
			MonsterList(viewModel: gameViewModel, selection: $selectedMonsterID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 120, ideal: 200, max: 240)
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
				gameViewModel.set(id: selectedGameID)

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
				if let selectedGameID {
					gameViewModel.set(id: selectedGameID)
				}
			} else {
				selectedGameID = nil
				gameViewModel.set()
			}
		}
		.onChange(of: selectedGameID, perform: gameViewModel.set(id:))
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
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
@available(watchOS, unavailable)
struct NavigationSplitViewHostBackport: View {
	let viewModel: HomeViewModel

	@Binding
	var selectedGameID: HomeItemViewModel.ID?

	@Binding
	var selectedMonsterID: MonsterViewModel.ID?

	@State
	private var gameViewModel = GameViewModel()

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationView {
#if os(macOS)
			Sidebar(viewModel: viewModel, selection: $selectedGameID)
			MonsterList(viewModel: gameViewModel, selection: $selectedMonsterID)
#else
			SidebarBackport(viewModel: viewModel, selection: $selectedGameID)
			GamePage(viewModel: gameViewModel) { item in
				MonsterSelectableListItem(viewModel: item, selection: $selectedMonsterID)
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
				gameViewModel.set(id: selectedGameID)

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
				if let selectedGameID {
					gameViewModel.set(id: selectedGameID)
				}
			} else {
				selectedGameID = nil
				gameViewModel.set()
			}
		}
		.onChange(of: selectedGameID, perform: gameViewModel.set(id:))
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
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
