import Foundation
import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
struct NavigationStackHost: View {
	private let viewModel: HomeViewModel

	@Binding
	private var path: [MARoute]

	init(_ viewModel: HomeViewModel,
		 path: Binding<[MARoute]>) {
		self.viewModel = viewModel
		self._path = path
	}

	var body: some View {
		NavigationStack(path: $path) {
			HomeView(viewModel: viewModel)
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(gameId):
						if let viewModel = GameViewModel(id: gameId) {
							GameView(viewModel: viewModel)
						} else {
							EmptyView()
						}
					case let .monster(gameId, monsterId):
						if let viewModel = MonsterViewModel(id: monsterId, for: gameId) {
							MonsterView(viewModel: viewModel)
						} else {
							EmptyView()
						}
					}
				}
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct NavigationStackHostBackport: View {
	private let viewModel: HomeViewModel

	@State
	private var selectedGameID: String?

	@State
	private var selectedMonsterID: String?

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		NavigationView {
			HomeViewBackport(viewModel: viewModel,
							 selectedGameID: $selectedGameID,
							 selectedMonsterID: $selectedMonsterID)
		}
		.navigationViewStyle(.stack)
	}
}

#endif
