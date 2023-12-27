import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
struct HomeView: View {
	@Environment(\.presentSettingsSheetAction)
	private var presentSettingsSheetAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			NavigationLink(value: MARoute.game(gameID: item.id)) {
				Text(verbatim: item.name)
			}
		}
		.modifier(SharedGameListModifier(state: viewModel.state) {
			presentSettingsSheetAction()
		})
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct HomeViewBackport: View {
	@Environment(\.presentSettingsSheetAction)
	private var presentSettingsSheetAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	var selectedGameID: String?

	@Binding
	var selectedMonsterID: String?

	var body: some View {
		List(viewModel.state.data ?? []) { item in
			NavigationLink(tag: item.id, selection: $selectedGameID) {
				LazyView {
					let viewModel = GameViewModel(id: item.id)!
					GameViewBackport(viewModel: viewModel,
									 selectedMonsterID: $selectedMonsterID)
				}
			} label: {
				Text(verbatim: item.name)
			}
		}
		.modifier(SharedGameListModifier(state: viewModel.state) {
			presentSettingsSheetAction()
		})
	}
}

#Preview {
	let viewModel = HomeViewModel()
	if #available(iOS 16.0, watchOS 9.0, *) {
		return HomeView(viewModel: viewModel)
	} else {
		return HomeViewBackport(viewModel: viewModel,
								selectedGameID: .constant(nil),
								selectedMonsterID: .constant(nil))
	}
}

#endif
