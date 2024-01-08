import Foundation
import MonsterAnalyzerCore

struct HomeItemViewModel: Identifiable, Hashable {
	let id: String
	let name: String

	init(id: String, name: String) {
		self.id = id
		self.name = name
	}

	init(game: Game) {
		self.id = game.id
		self.name = game.name
	}
}

final class HomeViewModel: ObservableObject {
	let app: App

	@Published
	private(set) var state: RequestState = .ready

	@Published
	private(set) var items: [HomeItemViewModel] = []

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app

		let scheduler = DispatchQueue.main
		app.$state.removeData().receive(on: scheduler).assign(to: &$state)
		app.$state
			.map { state in
				switch state {
				case let .complete(data: games):
					games.map(HomeItemViewModel.init)
				default:
					[]
				}
			}
			.removeDuplicates()
			.receive(on: scheduler)
			.assign(to: &$items)
	}

	func fetchData() {
		app.fetchIfNeeded()
	}
}

// MARK: - Equatable

extension HomeViewModel: Equatable {
	static func == (lhs: HomeViewModel, rhs: HomeViewModel) -> Bool {
		false
	}
}
