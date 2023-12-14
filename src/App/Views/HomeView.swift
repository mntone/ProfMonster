import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
struct HomeView: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	var body: some View {
		List(viewModel.items) { item in
			NavigationLink(value: item.routeValue) {
				Text(verbatim: item.name)
			}
		}
		.leadingToolbarItemBackport {
			Button("home.settings", systemImage: "gearshape.fill") {
				settingsAction?.present()
			}
		}
		.navigationTitle("home.title")
		.task {
			viewModel.fetchData()
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct HomeViewBackport: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private(set) var viewModel: HomeViewModel

	@Binding
	private(set) var selectedGameID: String?

	@Binding
	private(set) var selectedMonsterID: String?

	var body: some View {
		List(viewModel.items) { item in
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
		.leadingToolbarItemBackport {
			Button("home.settings", systemImage: "gearshape.fill") {
				settingsAction?.present()
			}
		}
		.navigationTitle("home.title")
		.task {
			viewModel.fetchData()
		}
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
