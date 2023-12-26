import Combine
import Foundation
import protocol Swinject.Resolver

public final class App: FetchableEntity<[Game]>, Entity {
	let resolver: Resolver

	public let settings = Settings()

	public var app: App? {
		self
	}

	public init(resolver: Resolver) {
		guard let dataSource = resolver.resolve(DataSource.self) else {
			fatalError()
		}
		self.resolver = resolver
		super.init(dataSource: dataSource)
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

	func findMonster(by id: String, of gameID: String) -> Monster? {
		findGame(by: gameID)?.findMonster(by: id)
	}
}
