import Combine
import Foundation
import Swinject

public final class App: FetchableEntity, Entity {
	private let _container: Container

	@Published
	public private(set) var games: [Game] = []

	public init(container: Container,
				dataSource: MHDataSource) {
		self._container = container
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading

			_dataSource.getConfig()
				.map { [_container, _dataSource] config in
					config.titles.map { title in
						Game(container: _container, dataSource: _dataSource, json: title)
					}
				}
				.catch { error in
					self._handle(error: error)
					return Empty<[Game], Never>()
				}
				.handleEvents(receiveCompletion: { completion in
					if case .finished = completion {
						self.state = .complete
					}
				})
				.assign(to: &$games)
		}
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
