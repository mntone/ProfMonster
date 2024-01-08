import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
struct NavigationSplitViewHost: View {
	@StateObject
	private var viewModel = HomeViewModel()

	@Binding
	private(set) var selectedGameID: HomeItemViewModel.ID?

	@Binding
	private(set) var selectedMonsterID: MonsterViewModel.ID?

#if os(iOS)
	@State
	private var screenWidth: CGFloat = 0
#endif

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationSplitView {
			Sidebar(viewModel: viewModel, selection: $selectedGameID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 120, ideal: 150, max: 180)
#endif
		} content: {
			MonsterList(id: selectedGameID, selection: $selectedMonsterID)
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 240)
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
			.navigationSplitViewColumnWidth(min: 480, ideal: 480)
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
				if let selectedMonsterID {
					monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)
				}
			}
		}
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
		.environment(\.settings, viewModel.app.settings)
	}

	private func updateMonsterViewModel(of id: String?) {
		if let selectedGameID,
		   let id = id?.split(separator: ";", maxSplits: 1).last.map(String.init) {
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
	@StateObject
	private var viewModel = HomeViewModel()

	@Binding
	private(set) var selectedGameID: HomeItemViewModel.ID?

	@Binding
	private(set) var selectedMonsterID: MonsterViewModel.ID?

	@State
	private var monsterViewModel: MonsterViewModel? = nil

	var body: some View {
		NavigationView {
#if os(macOS)
			Sidebar(viewModel: viewModel, selection: $selectedGameID)
				.frame(minWidth: 120, idealWidth: 150, maxWidth: 180)
			MonsterList(id: selectedGameID, selection: $selectedMonsterID)
				.frame(minWidth: 150, idealWidth: 200, maxWidth: 240)
#else
			SidebarBackport(viewModel: viewModel, selection: $selectedGameID)
			GamePage(id: selectedGameID) { item in
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
				if let selectedMonsterID {
					monsterViewModel = MonsterViewModel(id: selectedMonsterID, for: selectedGameID)
				}
			}
		}
		.onChange(of: selectedMonsterID, perform: updateMonsterViewModel)
		.environment(\.settings, viewModel.app.settings)
	}

	private func updateMonsterViewModel(of id: String?) {
		if let selectedGameID,
		   let id = id?.split(separator: ";", maxSplits: 1).last.map(String.init) {
			monsterViewModel = MonsterViewModel(id: id, for: selectedGameID)
		} else {
			monsterViewModel = nil
		}
	}
}
