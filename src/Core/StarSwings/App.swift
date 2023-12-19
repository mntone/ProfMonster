import Combine
import Foundation
import protocol Swinject.Resolver

public final class App: FetchableEntity, Entity {
	let resolver: Resolver

	@Published
	public private(set) var games: [Game] = []

	public init(resolver: Resolver) {
		guard let dataSource = resolver.resolve(DataSource.self) else {
			fatalError()
		}
		self.resolver = resolver
		super.init(dataSource: dataSource)
	}

	override func _fetch() async throws {
		let games = try await _dataSource.getConfig().titles.map { title in
			Game(resolver: resolver, dataSource: _dataSource, json: title)
		}
		self.games = games
	}

	public func resetMemoryCache() {
		_lock.withLock {
			guard case .complete = state else { return }
			defer { state = .ready }

			games.forEach { game in
				game.resetMemoryCache()
			}
			games.removeAll()
		}
	}
}

// MARK: - Supported Functions

public extension App {
	func findGame(by id: String) -> Game? {
		games.first { game in
			game.id == id
		}
	}
}
