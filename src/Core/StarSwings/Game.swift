import Combine
import Foundation
import Swinject

public final class Game: FetchableEntity, Entity {
	private let _container: Container

	public let id: String
	public let name: String

	public private(set) var languageService: LanguageService = PassthroughtLanguageService()

	@Published
	public private(set) var monsters: [Monster] = []

	public private(set) var hasChanges: Bool = false

	@Published
	public var isFavorite: Bool? = nil {
		willSet {
			hasChanges = true
		}
	}

	init(container: Container,
		 dataSource: MHDataSource,
		 json: MHConfigTitle) {
		self._container = container
		self.id = json.id

		let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.names.keys)
		self.name = json.names[preferredLocale]!
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading

			_dataSource.getGame(of: id)
				.flatMap { [weak self] json in
					guard let self else { fatalError() }

					let langsvc = _container.resolve(LanguageService.self, argument: json.localization)!
					return self._dataSource.getLocalization(of: langsvc.localeKey, for: self.id).map { localization in
						langsvc.register(dictionary: localization.states, for: .state)
						self.languageService = langsvc

						return json.monsters.map { monsterID in
							Monster(monsterID,
									gameID: self.id,
									dataSource: self._dataSource,
									languageService: langsvc,
									localization: localization.monsters.first(where: { m in m.id == monsterID })!)
						}
					}
				}
				.catch { error in
					self._handle(error: error)
					return Empty<[Monster], Never>()
				}
				.handleEvents(receiveCompletion: { completion in
					if case .finished = completion {
						self.state = .complete
					}
				})
				.assign(to: &$monsters)
		}
	}

	public func resetMemoryCache() {
		_lock.withLock {
			guard case .complete = state else { return }
			defer { state = .ready }
			monsters.removeAll()
		}
	}
}

// MARK: - Supported Functions

public extension Game {
	func findMonster(by id: String) -> Monster? {
		monsters.first { monster in
			monster.id == id
		}
	}
}
