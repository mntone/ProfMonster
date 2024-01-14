import Combine
import Foundation
import protocol Swinject.Resolver

public final class App: FetchableEntity<[Game]>, Entity {
	private let resolver: Resolver
	private let storage: Storage

	public let logger: Logger
	public let settings = Settings()

	public init(resolver: Resolver) {
		guard let logger = resolver.resolve(Logger.self) else {
			fatalError("Failed to get Logger.")
		}
		guard let storage = resolver.resolve(Storage.self) else {
			logger.fault("Failed to get Storage")
		}
		guard let dataSource = resolver.resolve(DataSource.self) else {
			logger.fault("Failed to get DataSource")
		}

		self.resolver = resolver
		self.logger = logger
		self.storage = storage
#if DEBUG
		super.init(dataSource: dataSource, delayed: settings.delayNetworkRequest)
#else
		super.init(dataSource: dataSource)
#endif
	}

	public func getCacheSize() async -> UInt64? {
		await Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return nil }
			return self.storage.size
		}.value
	}

	public func resetAllData() -> Task<Void, Never> {
		Task.detached(priority: .utility) { [weak self] in
			guard let self else { return }
			self.logger.notice("Reset all data.")
			self.storage.resetAll()
			self.resetMemoryCache()
		}
	}

	public func resetMemoryData() {
		self.logger.notice("Reset memory cache from user operation.")
		self.resetMemoryCache()
	}

	@discardableResult
	public func prefetch(of gameID: String) async throws -> Game? {
		guard let games = try await fetch() else {
			return nil
		}
		let game = games.first { game in
			game.id == gameID
		}
		return game
	}

	override func _fetch() async throws -> [Game] {
		let config = try await _dataSource.getConfig()

		// Check data format version.
		guard config.version == MHConfig.currentVersion else {
			throw StarSwingsError.notSupported
		}

		let games = config.titles.map { title in
			Game(app: self, resolver: resolver, dataSource: _dataSource, json: title)
		}
		return games
	}

	private func resetMemoryCache() {
		_lock.withLock {
			guard case .complete = state else { return }
			defer { state = .ready }

			if var games = state.data {
				games.forEach { game in
					game.resetMemoryCache()
				}
				games.removeAll()
			}
		}
	}
}

// MARK: - Supported Functions

public extension App {
	func findGame(by id: String) -> Game? {
		guard let games = state.data else {
			return nil
		}

		return games.first { game in
			game.id == id
		}
	}

	func findMonster(by id: String) -> Monster? {
		guard let gameID = id.split(separator: ":", maxSplits: 1).first,
			  let game = findGame(by: String(gameID)) else {
			return nil
		}
		return game.findMonster(by: id)
	}

	func prefetch(monsterOf monsterID: String) async throws -> Monster? {
		guard let gameID = monsterID.split(separator: ":", maxSplits: 1).first,
			  let game = try await prefetch(of: String(gameID)) else {
			return nil
		}

		let monster = try await game.prefetch(of: monsterID)
		return monster
	}
}
