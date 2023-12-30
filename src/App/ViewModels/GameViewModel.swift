import Combine
import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ObservableObject, Identifiable {
	private let game: Game

	@Published
	private(set) var state: StarSwingsState<[GameGroupViewModel]> = .ready

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
			// Create view model from domain model
			.mapData { monsters in
				monsters.map(GameItemViewModel.init)
			}

		// Favorite Group
		let favorites = getState
			.flatMap { state in
				switch state {
				case let .complete(data: monsters):
					return monsters
						.sorted()
						.map { monster in
							monster.$isFavorited.map { favorited -> GameItemViewModel? in
								favorited ? monster : nil
							}
						}
						.combineLatest
						.map { monsters -> [GameItemViewModel] in
							monsters.compactMap { monster in
								monster
							}
						}
						.eraseToAnyPublisher()
				default:
					return Just<[GameItemViewModel]>([])
						.eraseToAnyPublisher()
				}
			}
			.map { items -> GameGroupViewModel? in
				guard !items.isEmpty else { return nil }

				return GameGroupViewModel(gameID: game.id, type: .favorite, items: items)
			}

		// Search Text
		let searchText = Just("")
			.merge(with: $searchText.debounce(for: 0.333, scheduler: DispatchQueue.global(qos: .userInitiated)))
			.removeDuplicates()

		// All Groups
		getState
#if os(watchOS)
			// Merge the fav group into groups
			.combineLatest(favorites) { (state: StarSwingsState<[GameItemViewModel]>, fav: GameGroupViewModel?) -> StarSwingsState<[GameGroupViewModel]> in
				state.mapData { monsters in
					let groupsExceptFav = GameGroupViewModel(gameID: game.id, type: .inGame, items: monsters)

					let groups: [GameGroupViewModel]
					if let fav {
						groups = [fav, groupsExceptFav]
					} else {
						groups = [groupsExceptFav]
					}
					return groups
				}
			}
#else
			// Merge the fav group into sorted or splited groups
			.combineLatest(favorites, $sort) { (state: StarSwingsState<[GameItemViewModel]>, fav: GameGroupViewModel?, sort: Sort) -> StarSwingsState<[GameGroupViewModel]> in
				state.mapData { (monsters: [GameItemViewModel]) -> [GameGroupViewModel] in
					let groups: [GameGroupViewModel]
					switch sort {
					case .inGame:
						let groupsExceptFav = GameGroupViewModel(gameID: game.id, type: .inGame, items: monsters)
						if let fav {
							groups = [fav, groupsExceptFav]
						} else {
							groups = [groupsExceptFav]
						}
					case .name:
						let groupsExceptFav = GameGroupViewModel(gameID: game.id, type: .byName, items: monsters.sorted())
						if let fav {
							groups = [fav, groupsExceptFav]
						} else {
							groups = [groupsExceptFav]
						}
					case .type:
						let otherGroups = monsters
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

						if let fav {
							groups = [fav] + otherGroups
						} else {
							groups = otherGroups
						}
					}
					return groups
				}
			}
#endif
			// Filter search word
			.combineLatest(searchText) { (state: StarSwingsState<[GameGroupViewModel]>, searchText: String) -> StarSwingsState<[GameGroupViewModel]> in
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
			// Receive on the main dispatcher
			.receive(on: DispatchQueue.main)
			.assign(to: &$state)

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
