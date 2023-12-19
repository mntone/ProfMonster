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

extension GameItemViewModel: Equatable {
	static func == (lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.id == rhs.id && lhs.gameID == rhs.gameID
	}
}

extension GameItemViewModel: Comparable {
	static func <(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.name < rhs.name
	}
}

final class GameViewModel: ObservableObject, Identifiable {
	private let game: Game

	@Published
	private(set) var state: StarSwingsState<[GameItemViewModel]> = .ready

	@Published
	var sort: Sort = .inGame

	@Published
	var searchText: String = ""

	init(_ game: Game) {
		self.game = game

		let getState = game.$state
			.mapData { monsters in
				monsters.map(GameItemViewModel.init)
			}
		let updateSearchText = Just("").merge(with: $searchText.debounce(for: 0.333, scheduler: DispatchQueue.global(qos: .userInitiated)))
#if os(watchOS)
		getState.combineLatest(updateSearchText) { (state: StarSwingsState<[GameItemViewModel]>, searchText: String) -> StarSwingsState<[GameItemViewModel]> in
			state.mapData { monsters in
				Self.filter(searchText, from: monsters, languageService: game.languageService)
			}
		}
		.receive(on: DispatchQueue.main)
		.assign(to: &$state)
#else
		getState.combineLatest($sort, updateSearchText) { (state: StarSwingsState<[GameItemViewModel]>, sort: Sort, searchText: String) -> StarSwingsState<[GameItemViewModel]> in
			state.mapData { monsters in
				let filteredMonster = Self.filter(searchText, from: monsters, languageService: game.languageService)
				switch sort {
				case .inGame:
					return filteredMonster
				case .name:
					return filteredMonster.sorted()
				}
			}
		}
		.removeDuplicates { prev, cur in
			switch (prev, cur) {
			case (.ready, .ready), (.loading, .loading):
				return true
			case let (.complete(prevData), .complete(curData)):
				return prevData == curData
			default:
				return false
			}
		}
		.receive(on: DispatchQueue.main)
		.assign(to: &$state)
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
							   languageService: LanguageService) -> [GameItemViewModel] {
		if searchText.isEmpty {
			return monsters
		} else {
			let normalizedText = languageService.normalize(searchText)
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
