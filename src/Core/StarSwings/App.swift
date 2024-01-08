import Combine
import Foundation
import protocol Swinject.Resolver

public final class App: FetchableEntity<[Game]>, Entity {
	private let resolver: Resolver
	private let storage: Storage

	public let settings = Settings()

	public init(resolver: Resolver) {
		guard let storage = resolver.resolve(Storage.self),
			  let dataSource = resolver.resolve(DataSource.self) else {
			fatalError()
		}
		self.resolver = resolver
		self.storage = storage
		super.init(dataSource: dataSource)
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
			self.storage.resetAll()
			self.resetMemoryCache()
		}
	}

	@discardableResult
	public func prefetch(of gameID: String) async -> Game? {
		guard let games = await fetch(priority: .userInitiated).value else {
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

	public func resetMemoryCache() {
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
}
