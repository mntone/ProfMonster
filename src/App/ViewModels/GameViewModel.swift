import Combine
import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ObservableObject {
	private let app: App

	private var game: Game?
	private var cancellable: Cancellable?

	@Published
	private(set) var state: RequestState = .ready

	@Published
	private(set) var items: [GameGroupViewModel] = []

#if !os(watchOS)
	@Published
	var sort: Sort {
		didSet {
			app.settings.sort = sort
		}
	}
#endif

	@Published
	var searchText: String = ""

	var name: String? {
		@inline(__always)
		get {
			game?.name
		}
	}

	private var searchTextPublisher: some Publisher<String, Never> {
		@inline(__always)
		get {
			Just("")
				.merge(with: $searchText.debounce(for: 0.333, scheduler: DispatchQueue.global(qos: .userInitiated)))
				.removeDuplicates()
		}
	}

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app
#if !os(watchOS)
		self.sort = app.settings.sort // Do not track
#endif
	}

	func set(domain game: Game) {
		game.fetchIfNeeded()

		let scheduler = DispatchQueue.main
		game.$state.removeData().receive(on: scheduler).assign(to: &$state)

		let items = game.$state
			// Create view model from domain model
			.map { state -> [GameItemViewModel] in
				switch state {
				case let .complete(data: monsters):
					monsters.map(GameItemViewModel.init)
				default:
					[]
				}
			}
			.removeDuplicates()
			.multicast(subject: PassthroughSubject())

		// Favorite Group
		let favorites = items
			.map { (monsters: [GameItemViewModel]) in
				monsters
					.sorted()
					.map { monster in
						monster.$isFavorited.map { favorited -> IdentifyHolder<GameItemViewModel>? in
							return favorited ? IdentifyHolder(monster, prefix: "f") : nil
						}
					}
					.combineLatest
					.map { monsters -> GameGroupViewModel? in
						let items = monsters.compactMap { monster in
							monster
						}
						guard !items.isEmpty else { return nil }

						return GameGroupViewModel(gameID: game.id, type: .favorite, items: items)
					}
			}
			.switchToLatest()

		// All Groups
		items
			// Sort and split groups
#if os(watchOS)
			.map { [sort = app.settings.sort] (m: [GameItemViewModel]) -> [GameGroupViewModel] in
				let monsters = m.map { monster in
					IdentifyHolder(monster)
				}
				let groups = Self.sortMonsters(monsters, sort: sort, gameID: game.id)
				return groups
			}
#else
			.combineLatest($sort) { (m: [GameItemViewModel], sort: Sort) -> [GameGroupViewModel] in
				let monsters = m.map { monster in
					IdentifyHolder(monster)
				}
				let groups = Self.sortMonsters(monsters, sort: sort, gameID: game.id)
				return groups
			}
#endif
			// Merge the fav group into groups
			.combineLatest(favorites) { (groupsExceptFav: [GameGroupViewModel], fav: GameGroupViewModel?) -> [GameGroupViewModel] in
				let groups: [GameGroupViewModel]
				if let fav {
					groups = [fav] + groupsExceptFav
				} else {
					groups = groupsExceptFav
				}
				return groups
			}
			// Filter search word
			.combineLatest(searchTextPublisher) { [settings = app.settings] (groups: [GameGroupViewModel], searchText: String) -> [GameGroupViewModel] in
				if searchText.isEmpty {
					return groups
				}

				let normalizedSearchText = game.languageService.normalize(forSearch: searchText)
				return groups.compactMap { group -> GameGroupViewModel? in
#if !os(watchOS)
					if !settings.includesFavoriteGroupInSearchResult && group.type.isFavorite {
						return nil
					}
#endif

					let filtered = group.items.filter { monster in
						monster.content.keywords.contains { keyword in
							keyword.contains(normalizedSearchText)
						}
					}
					guard !filtered.isEmpty else {
						return nil
					}

					return GameGroupViewModel(gameID: group.gameID, type: group.type, items: filtered)
				}
			}
			// Receive on the main dispatcher
			.receive(on: scheduler)
			.assign(to: &$items)

		// Connect to multicast publisher.
		cancellable = items.connect()

		// Set current
		self.game = game
	}

	private static func sortMonsters(_ monsters: [IdentifyHolder<GameItemViewModel>], sort: Sort, gameID: String) -> [GameGroupViewModel] {
		let groups: [GameGroupViewModel]
		switch sort {
		case let .inGame(reversed):
			let groupsExceptFav = GameGroupViewModel(gameID: gameID, type: .inGame(reversed: reversed), items: reversed ? monsters.reversed() : monsters)
			groups = [groupsExceptFav]
		case let .name(reversed):
			let groupsExceptFav = GameGroupViewModel(gameID: gameID, type: .byName(reversed: reversed), items: reversed ? monsters.sorted(by: >) : monsters.sorted())
			groups = [groupsExceptFav]
		case let .type(reversed):
			let unsortedGroups = monsters
				.reduce(into: [:]) { (result: inout [String: [IdentifyHolder<GameItemViewModel>]], next: IdentifyHolder<GameItemViewModel>) in
					if let items = result[next.content.type] {
						result[next.content.type] = items + [next]
					} else {
						result[next.content.type] = [next]
					}
				}
				.map { id, items in
					GameGroupViewModel(gameID: gameID, type: .type(id: id, reversed: reversed), items: reversed ? items.sorted(by: >) : items.sorted())
				}
			groups = reversed ? unsortedGroups.sorted(by: >) : unsortedGroups.sorted()
		}
		return groups
	}
}

// MARK: - Set data

extension GameViewModel {
	func set() {
		self.game = nil
		self.items = []
	}

	@discardableResult
	@inline(__always)
	func set(id: String) -> Bool {
		guard let game = app.findGame(by: id) else {
			app.logger.notice("Failed to get the game (id: \(id))")
			return false
		}

		set(domain: game)
		return true
	}

	@inline(__always)
	func set(id: String?) {
		if let id {
			set(id: id)
		} else {
			set()
		}
	}
}

// MARK: - Identifiable

extension GameViewModel: Identifiable {
	var id: String? {
		@inline(__always)
		get {
			game?.id
		}
	}
}
