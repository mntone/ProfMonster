import Combine
import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ObservableObject {
	private let app: App

	private var game: Game?
	private var task: Task<Void, Never>?
	private var cancellable: Cancellable?

	@Published
	private(set) var state: RequestState = .ready

	@Published
	private(set) var items: [GameGroupViewModel] = []

	var itemsCount: Int {
		Set(items.lazy.flatMap(\.items).map(\.content.id)).count
	}

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

	deinit {
		if let task {
			self.task = nil
			task.cancel()
		}
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
						monster.$isFavorited.map { [weak monster] favorited -> IdentifyHolder<GameItemViewModel>? in
							guard let monster else { return nil }
							return favorited ? IdentifyHolder(monster, prefix: "F") : nil
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
			.map { [sort = app.settings.sort] (monsters: [GameItemViewModel]) -> [GameGroupViewModel] in
				let groups = Self.sortMonsters(monsters, sort: sort, gameID: game.id)
				return groups
			}
#else
			.combineLatest($sort) { (monsters: [GameItemViewModel], sort: Sort) -> [GameGroupViewModel] in
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

	private static func sortMonsters(_ baseMonsters: [GameItemViewModel], sort: Sort, gameID: String) -> [GameGroupViewModel] {
		let groups: [GameGroupViewModel]
		switch sort {
		case let .inGame(reversed):
			let monsters = baseMonsters.map { monster in
				IdentifyHolder(monster)
			}
			let groupsExceptFav = GameGroupViewModel(gameID: gameID, type: .inGame(reversed: reversed), items: reversed ? monsters.reversed() : monsters)
			groups = [groupsExceptFav]
		case let .name(reversed):
			let monsters = baseMonsters.map { monster in
				IdentifyHolder(monster)
			}
			let groupsExceptFav = GameGroupViewModel(gameID: gameID, type: .byName(reversed: reversed), items: reversed ? monsters.sorted(by: >) : monsters.sorted())
			groups = [groupsExceptFav]
		case let .type(reversed):
			let unsortedGroups = baseMonsters
				.map { monster in
					IdentifyHolder(monster)
				}
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
		case let .weakness(reversed):
			let unsortedGroups = baseMonsters
				.reduce(into: [:]) { (result: inout [Attack: [GameItemViewModel]], next: GameItemViewModel) in
					guard let weaknesses = next.weaknesses else { return }

					if weaknesses.contains(where: { $0.1.fire >= .effective }) {
						if let items = result[.fire] {
							result[.fire] = items + [next]
						} else {
							result[.fire] = [next]
						}
					}
					if weaknesses.contains(where: { $0.1.water >= .effective }) {
						if let items = result[.water] {
							result[.water] = items + [next]
						} else {
							result[.water] = [next]
						}
					}
					if weaknesses.contains(where: { $0.1.thunder >= .effective }) {
						if let items = result[.thunder] {
							result[.thunder] = items + [next]
						} else {
							result[.thunder] = [next]
						}
					}
					if weaknesses.contains(where: { $0.1.ice >= .effective }) {
						if let items = result[.ice] {
							result[.ice] = items + [next]
						} else {
							result[.ice] = [next]
						}
					}
					if weaknesses.contains(where: { $0.1.dragon >= .effective }) {
						if let items = result[.dragon] {
							result[.dragon] = items + [next]
						} else {
							result[.dragon] = [next]
						}
					}
				}
				.map { element, baseItems in
					let items = baseItems.map { monster in
						IdentifyHolder(monster, prefix: element.prefix)
					}
					return GameGroupViewModel(gameID: gameID, type: .weakness(element: element, reversed: reversed), items: reversed ? items.sorted(by: >) : items.sorted())
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

		if let task {
			self.task = nil
			task.cancel()
		}

		self.items = []
	}

	@inline(__always)
	func set(id: String) {
		guard game?.id != id else {
			return
		}

		if let task {
			self.task = nil
			task.cancel()
		}

		if let game = app.findGame(by: id) {
			set(domain: game)
			return
		}

		self.task = Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return }

			guard let game = await app.prefetch(of: id) else {
				app.logger.notice("Failed to get the game (id: \(id))")
				return
			}

			DispatchQueue.main.async {
				self.set(domain: game)
			}
		}
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
