#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct NavigationStackHost: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		NavigationStack(path: coord.path) {
			HomePage(viewModel: viewModel)
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(id):
						GamePage(id: id)
					case let .monster(id):
						MonsterPage(id: id)
					}
				}
		}
		.environment(\.settings, viewModel.app.settings)
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationStackHostBackport: View {
	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		NavigationView {
			HomePageBackport(viewModel: viewModel)
		}
		.navigationViewStyle(.stack)
		.environment(\.settings, viewModel.app.settings)
	}
}

#endif
