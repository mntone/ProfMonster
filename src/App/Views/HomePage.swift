#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct HomePage: View {
	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items) { item in
			NavigationLink(item.name, value: MARoute.game(id: item.id))
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use HomePage instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use HomePage instead")
struct HomePageBackport: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = HomeViewModel()

	var body: some View {
		List(viewModel.items) { item in
			NavigationLink(item.name, tag: item.id, selection: $coord.selectedGameID) {
				GamePageBackport(id: item.id)
			}
		}
		.stateOverlay(viewModel.state)
		.modifier(SharedGameListModifier(viewModel: viewModel))
	}
}

@available(iOS 16.0, watchOS 9.0, *)
#Preview("Default") {
	NavigationStack {
		HomePage()
	}
	.environmentObject(CoordinatorViewModel())
}

#Preview("Backport") {
	NavigationView {
		HomePageBackport()
	}
	.navigationViewStyle(.stack)
	.environmentObject(CoordinatorViewModel())
}

#endif
