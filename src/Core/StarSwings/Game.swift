import Combine
import Foundation
import Swinject

public final class Game: FetchableEntity<[Monster]>, Entity {
	private let _resolver: Resolver

	public weak var app: App?

	public let id: String
	public let name: String

	public private(set) var languageService: LanguageService = PassthroughtLanguageService()

	public private(set) var hasChanges: Bool = false

	@Published
	public var isFavorite: Bool? = nil {
		willSet {
			hasChanges = true
		}
	}

	init(app: App,
		 resolver: Resolver,
		 dataSource: DataSource,
		 json: MHConfigTitle) {
		self.app = app
		self._resolver = resolver
		self.id = json.id

		let preferredLocale = LanguageUtil.getPreferredLanguageKey(json.names.keys)
		self.name = json.names[preferredLocale]!
		super.init(dataSource: dataSource)
	}

	@discardableResult
	public func prefetch(of monsterID: String) async -> Monster? {
		guard let monsters = await fetch(priority: .userInitiated).value else {
			return nil
		}
		let monster = monsters.first { monster in
			monster.id == monsterID
		}
		return monster
	}

	override func _fetch() async throws -> [Monster] {
		let game = try await _dataSource.getGame(of: id)
		let langsvc = _resolver.resolve(LanguageService.self, argument: game.localization)!
		let localization = try await _dataSource.getLocalization(of: langsvc.localeKey, for: id)
		langsvc.register(dictionary: localization.states, for: .state)
		languageService = langsvc

		let app = self.app!
		let monsters = game.monsters.map { monsterID in
			Monster(app: app,
					id: monsterID,
					gameID: self.id,
					dataSource: self._dataSource,
					languageService: langsvc,
					localization: localization.monsters.first(where: { m in m.id == monsterID })!)
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
