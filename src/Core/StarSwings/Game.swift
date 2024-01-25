import Foundation
import protocol Swinject.Resolver

public final class Game: FetchableEntity<[Monster]>, Entity {
	public static let maxMonsters: Int = {
		min(AppUtil.monstersLimit, 1000)
	}()

	private let _logger: Logger
	private let _userDatabase: UserDatabase
	private let _resourceMapper: MonsterResourceMapper
	private let _physiologyMapper: PhysiologyMapper

	weak var app: App?

	public let id: String
	public let name: String

	public var copyright: String?
	public var url: URL?

	init(app: App,
		 resolver: Resolver,
		 dataSource: DataSource,
		 logger: Logger,
		 resourceMapper: MonsterResourceMapper,
		 physiologyMapper: PhysiologyMapper,
		 id: String,
		 localization: MHLocalizationGame) {
		guard let userDatabase = resolver.resolve(UserDatabase.self) else {
			logger.fault("Failed to get UserDatabase.")
		}

		self._logger = logger
		self._userDatabase = userDatabase
		self._resourceMapper = resourceMapper
		self._physiologyMapper = physiologyMapper

		self.app = app
		self.id = id
		self.name = localization.name
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
		self.copyright = game.copyright
		self.url = game.url.flatMap(URL.init(string:))

		if Task.isCancelled {
			throw StarSwingsError.cancelled
		}

		let app = self.app!
		let idPrefix = "\(id):"
		let udMonsters = _userDatabase.getMonsters(by: idPrefix)

		var monsters: [Monster] = []
		monsters.reserveCapacity(game.monsters.count)
		for jsonMonster in game.monsters {
			let id = idPrefix + jsonMonster.id
			let monster = Monster(app: app,
								  game: self,
								  id: id,
								  monster: jsonMonster,
								  dataSource: self._dataSource,
								  resourceMapper: _resourceMapper,
								  physiologyMapper: _physiologyMapper,
								  userDatabase: _userDatabase,
								  userData: udMonsters.first { udMonster in udMonster.id == id },
								  prefix: idPrefix,
								  reference: monsters)
			if let monster {
				monsters.append(monster)
				if monsters.count > Self.maxMonsters {
					break
				}
			}
		}
		return monsters
	}

	override func _resetChildStates() {
		if var monsters = state.data {
			monsters.forEach { monster in
				monster.resetState()
			}
			monsters.removeAll()
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
