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

extension GameItemViewModel: Comparable {
	static func <(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.name < rhs.name
	}
}

final class GameViewModel: ObservableObject, Identifiable {
	private let game: Game

	@Published
	private(set) var state: StarSwingsState = .ready

	@Published
	private(set) var items: [GameItemViewModel] = []

#if !os(watchOS)
	@Published
	var sort: Sort = .inGame
#endif

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
#if os(watchOS)
		getViewModel.combineLatest(updateSearchText) { (monsters: [GameItemViewModel], searchText: String) -> [GameItemViewModel] in
			Self.filter(searchText, from: monsters, textProcessor: textProcessor)
		}.assign(to: &$items)
#else
		getViewModel.combineLatest($sort, updateSearchText) { (monsters: [GameItemViewModel], sort: Sort, searchText: String) -> [GameItemViewModel] in
			let filteredMonster = Self.filter(searchText, from: monsters, textProcessor: textProcessor)
			switch sort {
			case .inGame:
				return filteredMonster
			case .name:
				return filteredMonster.sorted()
			}
		}.assign(to: &$items)
#endif
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

	private static func filter(_ searchText: String,
							   from monsters: [GameItemViewModel],
							   textProcessor: TextProcessor) -> [GameItemViewModel] {
		if searchText.isEmpty {
			return monsters
		} else {
			let normalizedText = textProcessor.normalize(searchText)
			let filteredMonsters = monsters.filter { monster in
				monster.keywords.contains { keyword in
					keyword.contains(normalizedText)
				}
			}
			return filteredMonsters
		}
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
