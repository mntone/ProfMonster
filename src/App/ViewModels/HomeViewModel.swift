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
				case .ready:
					self.state = .loading
					self.items = []
					self.objectWillChange.send()
					self.app.fetchIfNeeded()
				case .loading:
					if self.state != .loading {
						self.state = .loading
						self.objectWillChange.send()
					}
				case let .complete(games):
					self.state = .complete
					self.items = games.map(HomeItemViewModel.init)
					self.objectWillChange.send()
				case let .failure(reset, error):
					self.state = .failure(reset: reset, error: error)
					self.objectWillChange.send()
				}
			}
	}

	func refresh() {
		app.fetchIfNeeded()
	}
}

// MARK: - Equatable

extension HomeViewModel: Equatable {
	static func == (lhs: HomeViewModel, rhs: HomeViewModel) -> Bool {
		false
	}
}
