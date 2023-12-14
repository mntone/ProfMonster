import Combine
import Foundation

public final class Game: FetchableEntity, Entity {
	public let id: String
	public let name: String
	public let locale: String

	@Published
	public private(set) var monsters: [Monster] = []

	public private(set) var hasChanges: Bool = false

	@Published
	public var isFavorite: Bool? = nil {
		willSet {
			hasChanges = true
		}
	}

	init(dataSource: MHDataSource,
		 json: MHConfigTitle,
		 locale: String) {
		self.id = json.id

		let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.names.keys)
		self.name = json.names[preferredLocale]!
		self.locale = locale
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading

			_dataSource.getGame(of: id)
				.flatMap { [self] json in
					let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.localization)
					return self._dataSource.getLocalization(of: preferredLocale, for: self.id).map { localization in
						json.monsters.map { monsterID in
							Monster(monsterID,
									gameID: self.id,
									dataSource: self._dataSource,
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
