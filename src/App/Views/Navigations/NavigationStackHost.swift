#if !os(macOS)

import SwiftUI

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct NavigationStackHost: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel


	var body: some View {
		NavigationStack(path: coord.path) {
			HomePage()
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(id):
						GamePage(id: id)
					case let .monster(id):
						MonsterPage(id: id)
					}
				}
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(macOS, unavailable)
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationStackHostBackport: View {
	var body: some View {
		NavigationView {
			HomePageBackport()
		}
		.navigationViewStyle(.stack)
	}
}

#endif
