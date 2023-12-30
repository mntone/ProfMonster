import Combine
import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ObservableObject, Identifiable {
	private let game: Game

#if os(watchOS)
	@Published
	private(set) var state: StarSwingsState<[GameItemViewModel]> = .ready
#else
	@Published
	private(set) var state: StarSwingsState<[GameGroupViewModel]> = .ready
#endif

	@Published
	var sort: Sort {
		didSet {
			game.app?.settings.sort = sort
		}
	}

	@Published
	var searchText: String = ""

	init(_ game: Game) {
		self.game = game
		self.sort = game.app?.settings.sort ?? .inGame

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
		getState.combineLatest($sort) { (state: StarSwingsState<[GameItemViewModel]>, sort: Sort) -> StarSwingsState<[GameGroupViewModel]> in
			state.mapData { (monsters: [GameItemViewModel]) -> [GameGroupViewModel] in
				let groups: [GameGroupViewModel]
				switch sort {
				case .inGame:
					groups = [GameGroupViewModel(gameID: game.id, type: .inGame, items: monsters)]
				case .name:
					groups = [GameGroupViewModel(gameID: game.id, type: .byName, items: monsters.sorted())]
				case .type:
					groups = monsters
						.reduce(into: [:]) { (result: inout [String: [GameItemViewModel]], next: GameItemViewModel) in
							if let items = result[next.type] {
								result[next.type] = items + [next]
							} else {
								result[next.type] = [next]
							}
						}
						.map { id, items in
							GameGroupViewModel(gameID: game.id, type: .type(id: id), items: items.sorted())
						}
						.sorted()
				}
				return groups
			}
		}
		.combineLatest($searchText) { (state: StarSwingsState<[GameGroupViewModel]>, searchText: String) -> StarSwingsState<[GameGroupViewModel]> in
			state.mapData { groups in
				groups.compactMap { group in
					let monsters = Self.filter(searchText, from: group.items, languageService: game.languageService)
					guard !monsters.isEmpty else {
						return nil
					}
					return GameGroupViewModel(gameID: group.gameID, type: group.type, items: monsters)
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

		game.fetchIfNeeded()
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
