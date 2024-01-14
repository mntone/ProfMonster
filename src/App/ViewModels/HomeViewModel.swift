import Combine
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

	private var cancellable: AnyCancellable?

	private(set) var state: RequestState = .ready
	private(set) var items: [HomeItemViewModel] = []

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app

		cancellable = app.$state
			.receive(on: DispatchQueue.main)
			.sink { [weak self] state in
				guard let self else { return }
				switch state {
				case .ready, .loading:
					self.state = .loading
					self.items = []
				case let .complete(games):
					self.state = .complete
					self.items = games.map(HomeItemViewModel.init)
				case let .failure(date, error):
					self.state = .failure(date: date, error: error)
					self.items = []
				}
				self.objectWillChange.send()
			}
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
