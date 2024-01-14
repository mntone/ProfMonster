import Foundation
import protocol Swinject.Resolver

public final class Game: FetchableEntity<[Monster]>, Entity {
	private let _resolver: Resolver

	weak var app: App?

	public let id: String
	public let name: String

	public private(set) var languageService: LanguageService = PassthroughtLanguageService()

	init(app: App,
		 resolver: Resolver,
		 dataSource: DataSource,
		 json: MHConfigTitle) {
		self.app = app
		self._resolver = resolver
		self.id = json.id

		let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.names.keys)
		self.name = json.names[preferredLocale]!
#if DEBUG
		super.init(dataSource: dataSource, delayed: app.delayRequest)
#else
		super.init(dataSource: dataSource)
#endif
	}

	@discardableResult
	public func prefetch(of monsterID: String) async throws -> Monster? {
		guard let monsters = try await fetch() else {
			return nil
		}
		let monster = monsters.first { monster in
			monster.id == monsterID
		}
		return monster
	}

	override func _fetch() async throws -> [Monster] {
		let game = try await _dataSource.getGame(of: id)
		if Task.isCancelled {
			throw StarSwingsError.cancelled
		}

		let langsvc = _resolver.resolve(LanguageService.self, argument: game.localization)!
		let localization = try await _dataSource.getLocalization(of: langsvc.localeKey, for: id)
		langsvc.register(dictionary: localization.states, for: .state)
		languageService = langsvc
		let physiologyMapper = PhysiologyMapper(languageService: languageService)

		let app = self.app!
		let userdb = _resolver.resolve(UserDatabase.self)!
		let idPrefix = "\(id):"
		let udMonsters = userdb.getMonsters(by: idPrefix)

		var monsters: [Monster] = []
		monsters.reserveCapacity(game.monsters.count)
		for jsonMonster in game.monsters {
			let id = idPrefix + jsonMonster.id
			let monster = Monster(app: app,
								  id: id,
								  monster: jsonMonster,
								  dataSource: self._dataSource,
								  languageService: langsvc,
								  physiologyMapper: physiologyMapper,
								  localization: localization.monsters.first(where: { m in m.id == jsonMonster.id })!,
								  userDatabase: userdb,
								  userData: udMonsters.first { udMonster in udMonster.id == id },
								  prefix: idPrefix,
								  reference: monsters)
			monsters.append(monster)
		}
		return monsters
	}

	public func resetMemoryCache() {
		_lock.withLock {
			guard case .complete = state else { return }
			defer { state = .ready }

			if var monsters = state.data {
				monsters.removeAll()
			}
		}
	}
}

// MARK: - Equatable

extension Game: Equatable {
	public static func ==(lhs: Game, rhs: Game) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Supported Functions

public extension Game {
	func findMonster(by id: String) -> Monster? {
		guard let monsters = state.data else {
			return nil
		}

		return monsters.first { monster in
			monster.id == id
		}
	}
}
