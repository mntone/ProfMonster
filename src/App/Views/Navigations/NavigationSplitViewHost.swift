import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
struct NavigationSplitViewHost: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

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
			ZStack {
				Color(.monsterListBackground)

				if let gameViewModel {
					MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
				}
			}
			.navigationSplitViewColumnWidth(min: 160, ideal: 200, max: 240)
#else
			if let gameViewModel {
				MonsterList(viewModel: gameViewModel, selectedMonsterID: $selectedMonsterID)
			}
#endif
		} detail: {
			Group {
				if let monsterViewModel {
					MonsterView(viewModel: monsterViewModel)
				}
			}
#if os(macOS)
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
				selectedGameID = viewModel.items.first?.id
			}
		}
		.onChange(of: viewModel.items) { newValue in
			selectedMonsterID = nil
			selectedGameID = viewModel.items.first?.id
		}
		.onChange(of: selectedGameID) { newValue in
			if let newValue {
				gameViewModel = GameViewModel(id: newValue)!
			} else {
				gameViewModel = nil
			}
		}
		.onChange(of: selectedMonsterID) { newValue in
			if let selectedGameID,
			   let newValue {
				monsterViewModel = MonsterViewModel(id: newValue, for: selectedGameID)
			} else {
				monsterViewModel = nil
			}
		}
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use NavigationSplitViewHost instead")
@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use NavigationSplitViewHost instead")
struct NavigationSplitViewHostBackport: View {
	@ObservedObject
	private(set) var viewModel: HomeViewModel

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

			if let monsterViewModel {
				MonsterView(viewModel: monsterViewModel)
			} else {
				Color(.monsterBackground)
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
				selectedGameID = viewModel.items.first?.id
			}
		}
		.onChange(of: viewModel.items) { newValue in
			selectedMonsterID = nil
			selectedGameID = viewModel.items.first?.id
		}
		.onChange(of: selectedGameID) { newValue in
			if let newValue {
				gameViewModel = GameViewModel(id: newValue)!
			} else {
				gameViewModel = nil
			}
		}
		.onChange(of: selectedMonsterID) { newValue in
			if let selectedGameID,
			   let newValue {
				monsterViewModel = MonsterViewModel(id: newValue, for: selectedGameID)
			} else {
				monsterViewModel = nil
			}
		}
	}
}
