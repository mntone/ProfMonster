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
	private let app: App

	@Published
	private(set) var items: [HomeItemViewModel] = []

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app

		app.$games
			.map { games in
				games.map(HomeItemViewModel.init)
			}
			.receive(on: DispatchQueue.main)
			.assign(to: &$items)
	}

	func resetData() {
		app.resetMemoryCache()

		Task(priority: .utility) {
			app.fetchIfNeeded()
		}
	}

	func fetchData() {
		app.fetchIfNeeded()
	}
}
