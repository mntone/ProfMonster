import Combine
import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ObservableObject {
	private let app: App

	private var game: Game?
	private var task: Task<Void, Never>?
	private var cancellable: Cancellable?

#if os(macOS)
	@Published
	private(set) var disableAnimations: Bool = true
#endif

	@Published
	private(set) var state: RequestState = .ready

	@Published
	private(set) var items: [GameGroupViewModel] = []

#if !os(watchOS)
	@Published
	private(set) var hasSizes: Bool = false
#endif

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

	@Published
	var groupOption: GroupOption {
		didSet {
			app.settings.groupOption = groupOption
		}
	}
#endif

	@Published
	var searchText: String = ""

	var name: String {
		@inline(__always)
		get {
			game?.name ?? ""
		}
	}

	private var searchTextPublisher: some Publisher<String, Never> {
		@inline(__always)
		get {
			Just("")
				.merge(with: $searchText.debounce(for: 0.333, scheduler: DispatchQueue.global(qos: .userInitiated)))
				.removeDuplicates()
				.map(app.languageService.unsafelyUnwrapped.normalize(forSearch:))
#if os(macOS)
				.handleEvents(receiveOutput: { [weak self] _ in
					guard let self else { return }
					DispatchQueue.main.async {
						self.disableAnimations = false
					}
				})
#endif
		}
	}

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app

#if !os(watchOS)
		// Do not track
		self.groupOption = app.settings.groupOption
		self.sort = app.settings.sort
#endif
	}

	deinit {
		if let task {
			self.task = nil
			task.cancel()
		}
	}

	func refresh() {
		game?.fetchIfNeeded()
	}

	func set(domain game: Game) {
		// Reset current states.
		self.game = nil
		if let task {
			self.task = nil
			task.cancel()
		}

		game.fetchIfNeeded()

		// Load data from domain.
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

#if !os(watchOS)
		// Set to enable size sort.
		items
			.map { (monsters: [GameItemViewModel]) in
				monsters.allSatisfy { monster in
					monster.size != nil
				}
			}
			.receive(on: scheduler)
			.assign(to: &$hasSizes)
#endif

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
			.map { [sort = app.settings.sort, groupOption = app.settings.groupOption] (baseMonsters: [GameItemViewModel]) -> [GameGroupViewModel] in
				let monsters = Self.sortMonsters(baseMonsters, sort: sort)
				let groups = Self.groupMonsters(monsters, groupOption: groupOption, gameID: game.id)
				return groups
			}
#else
			.combineLatest($sort) { (monsters: [GameItemViewModel], sort: Sort) -> [GameItemViewModel] in
				let monsters = Self.sortMonsters(monsters, sort: sort)
				return monsters
			}
			.combineLatest($groupOption) { (monsters: [GameItemViewModel], groupOption: GroupOption) -> [GameGroupViewModel] in
				let groups = Self.groupMonsters(monsters, groupOption: groupOption, gameID: game.id)
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
#if os(macOS)
			// Disable animations
			.handleEvents(receiveOutput: { [weak self] _ in
				guard let self else { return }
				DispatchQueue.main.async {
					self.disableAnimations = true
				}
			})
#endif
			// Filter search word
			.combineLatest(searchTextPublisher) { [settings = app.settings] (groups: [GameGroupViewModel], searchText: String) -> [GameGroupViewModel] in
				if searchText.isEmpty {
					return groups
				}

				return groups.compactMap { group -> GameGroupViewModel? in
#if !os(watchOS)
					if !settings.includesFavoriteGroupInSearchResult && group.type.isFavorite {
						return nil
					}
#endif

					let filtered = group.items.filter { monster in
						monster.content.keywords.contains { keyword in
							keyword.contains(searchText)
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

	private static func sortMonsters(_ baseMonsters: [GameItemViewModel], sort: Sort) -> [GameItemViewModel] {
		let monsters: [GameItemViewModel]
		switch sort {
		case .inGame(false):
			monsters = baseMonsters
		case .inGame(true):
			monsters = baseMonsters.reversed()
		case .name(false, true):
			monsters = baseMonsters.sorted()
		case .name(true, true):
			monsters = baseMonsters.sorted(by: >)
		case .name(false, false):
			monsters = baseMonsters.sorted(by: AscendingSimpleSortkeyComparator.compare)
		case .name(true, false):
			monsters = baseMonsters.sorted(by: DescendingSimpleSortkeyComparator.compare)
#if !os(watchOS)
		case .size(false):
			monsters = baseMonsters.sorted(by: AscendingSizeComparator.compare)
		case .size(true):
			monsters = baseMonsters.sorted(by: DescendingSizeComparator.compare)
#endif
		}
		return monsters
	}

	private static func groupMonsters(_ baseMonsters: [GameItemViewModel], groupOption: GroupOption, gameID: String) -> [GameGroupViewModel] {
		let groups: [GameGroupViewModel]
		switch groupOption {
		case .none:
			let monsters = baseMonsters.map { monster in
				IdentifyHolder(monster)
			}
			let groupsExceptFav = GameGroupViewModel(gameID: gameID, type: .none, items: monsters)
			groups = [groupsExceptFav]
		case .type:
			groups = baseMonsters
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
					GameGroupViewModel(gameID: gameID, type: .type(id: id), items: items)
				}
				.sorted()
		case .weakness:
			groups = baseMonsters
				.reduce(into: [:]) { (result: inout [Attack?: [GameItemViewModel]], next: GameItemViewModel) in
					guard let weaknesses = next.weaknesses else { return }

					var added: Bool = false
					if weaknesses.contains(where: { $0.1.fire >= .effective }) {
						if let items = result[.fire] {
							result[.fire] = items + [next]
						} else {
							result[.fire] = [next]
						}
						added = true
					}
					if weaknesses.contains(where: { $0.1.water >= .effective }) {
						if let items = result[.water] {
							result[.water] = items + [next]
						} else {
							result[.water] = [next]
						}
						added = true
					}
					if weaknesses.contains(where: { $0.1.thunder >= .effective }) {
						if let items = result[.thunder] {
							result[.thunder] = items + [next]
						} else {
							result[.thunder] = [next]
						}
						added = true
					}
					if weaknesses.contains(where: { $0.1.ice >= .effective }) {
						if let items = result[.ice] {
							result[.ice] = items + [next]
						} else {
							result[.ice] = [next]
						}
						added = true
					}
					if weaknesses.contains(where: { $0.1.dragon >= .effective }) {
						if let items = result[.dragon] {
							result[.dragon] = items + [next]
						} else {
							result[.dragon] = [next]
						}
						added = true
					}
					if !added {
						if let items = result[.none] {
							result[.none] = items + [next]
						} else {
							result[.none] = [next]
						}
					}
				}
				.map { element, baseItems in
					let items = baseItems.map { monster in
						IdentifyHolder(monster, prefix: element?.prefix ?? "n")
					}
					return GameGroupViewModel(gameID: gameID, type: .weakness(element: element), items: items)
				}
				.sorted()
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

		if let game = app.findGame(by: id) {
			set(domain: game)
			return
		}

		self.task = Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return }

			guard let game = try? await app.prefetch(of: id) else {
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
