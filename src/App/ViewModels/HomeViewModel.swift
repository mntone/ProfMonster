import Foundation
import MonsterAnalyzerCore

final class HomeViewModel: ViewModelCache<GameViewModel>, ObservableObject {
	@Published
	private(set) var games: [GameViewModel]

	override init() {
		self.games = []
		super.init()
	}

	init(games: [GameViewModel]) {
		self.games = games
	}

	func loadIfNeeded() {
		guard games.isEmpty else {
			return
		}

		loadGamesData()
	}

	private func loadGamesData() {
		guard let client = MAApp.resolver.resolve(MHDataSource.self) else {
			fatalError()
		}

		client.getConfig()
#if DEBUG
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					debugPrint(error)
				}
			})
#endif
			.receive(on: DispatchQueue.main)
			.map { config in
				config.titles.map { title in
					let viewModel = self.getOrCreate(id: title.id)
					viewModel.updateName(title)
					return viewModel
				}
			}
			.replaceError(with: [])
			.assign(to: &$games)
	}

	override func clear() {
		games.forEach { game in
			game.clear()
		}
		self.clear()
	}

	func getOrCreate(id gameId: String) -> GameViewModel {
		getOrCreate(id: gameId) {
			GameViewModel(id: gameId)
		}
	}
}
