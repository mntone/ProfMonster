import Combine
import Foundation
import MonsterAnalyzerCore

struct GameItemViewModel: Identifiable, Hashable {
	let id: String
	let gameID: String
	let name: String
	let keywords: [String]

	init(id: String, gameID: String, name: String, keywords: [String]) {
		self.id = id
		self.gameID = gameID
		self.name = name
		self.keywords = keywords
	}

	init(monster: Monster) {
		self.id = monster.id
		self.gameID = monster.gameID
		self.name = monster.name
		self.keywords = monster.keywords
	}

#if DEBUG || targetEnvironment(simulator)
	init(id monsterID: String, gameID: String) {
		guard let app = MAApp.resolver.resolve(App.self),
			  let game = app.findGame(by: gameID),
			  let monster = game.findMonster(by: monsterID) else {
			fatalError()
		}
		self.id = monster.id
		self.gameID = monster.gameID
		self.name = monster.name
		self.keywords = monster.keywords
	}
#endif
}

final class GameViewModel: ObservableObject, Identifiable {
	private let game: Game

	@Published
	private(set) var state: StarSwingsState = .ready

	@Published
	private(set) var items: [GameItemViewModel] = []

	@Published
	var searchText: String = ""

	init(_ game: Game) {
		guard let textProcessor = MAApp.resolver.resolve(TextProcessor.self) else {
			fatalError()
		}
		self.game = game

		game.$state.receive(on: DispatchQueue.main).assign(to: &$state)

		let getViewModel = game.$monsters.map { monsters in
			monsters.map(GameItemViewModel.init)
		}
		let updateSearchText = Just("").merge(with: $searchText.debounce(for: 0.333, scheduler: DispatchQueue.main))
		getViewModel.combineLatest(updateSearchText) { monsters, searchText in
			if searchText.isEmpty {
				return monsters
			} else {
				let normalizedText = textProcessor.normalize(searchText)
				return monsters.filter { monster in
					monster.keywords.contains { keyword in
						keyword.contains(normalizedText)
					}
				}
			}
		}.assign(to: &$items)
	}

	convenience init?(id gameID: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let game = app.findGame(by: gameID) else {
			// TODO: Logging. Game is not found
			return nil
		}
		self.init(game)
	}

	func fetchData() {
		game.fetchIfNeeded()
	}

	var id: String {
		@inline(__always)
		get {
			game.id
		}
	}

	var name: String {
		@inline(__always)
		get {
			game.name
		}
	}
}

// MARK: - Equatable

extension GameViewModel: Equatable {
	static func == (lhs: GameViewModel, rhs: GameViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Hashable

extension GameViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
