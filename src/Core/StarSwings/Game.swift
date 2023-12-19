import Combine
import Foundation
import Swinject

public final class Game: FetchableEntity, Entity {
	private let _resolver: Resolver

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

	init(resolver: Resolver,
		 dataSource: DataSource,
		 json: MHConfigTitle) {
		self._resolver = resolver
		self.id = json.id

		let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.names.keys)
		self.name = json.names[preferredLocale]!
		super.init(dataSource: dataSource)
	}

	override func _fetch() async throws {
		let game = try await _dataSource.getGame(of: id)
		let langsvc = _resolver.resolve(LanguageService.self, argument: game.localization)!
		let localization = try await _dataSource.getLocalization(of: langsvc.localeKey, for: id)
		langsvc.register(dictionary: localization.states, for: .state)
		languageService = langsvc

		let monsters = game.monsters.map { monsterID in
			Monster(monsterID,
					gameID: self.id,
					dataSource: self._dataSource,
					languageService: langsvc,
					localization: localization.monsters.first(where: { m in m.id == monsterID })!)
		}
		self.monsters = monsters
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
