import Combine
import Foundation
import protocol Swinject.Resolver

public final class App: FetchableEntity, Entity {
	let resolver: Resolver

	@Published
	public private(set) var games: [Game] = []

	public init(resolver: Resolver) {
		guard let dataSource = resolver.resolve(MHDataSource.self) else {
			fatalError()
		}
		self.resolver = resolver
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading
		}

		_dataSource.getConfig()
			.map { [resolver, _dataSource] config in
				config.titles.map { title in
					Game(resolver: resolver, dataSource: _dataSource, json: title)
				}
			}
			.handleEvents(receiveCompletion: { [weak self] completion in
				guard let self else { fatalError() }
				self._handle(completion: completion)
			})
			.catch { error in
				return Empty<[Game], Never>()
			}
			.assign(to: &$games)
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
