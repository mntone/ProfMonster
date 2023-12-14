import Combine
import Foundation

public final class App: FetchableEntity, Entity {
	private let _locale: String

	@Published
	public private(set) var games: [Game] = []

	public init(dataSource: MHDataSource, locale: String) {
		self._locale = locale
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading

			_dataSource.getConfig()
				.map { [_dataSource, _locale] config in
					config.titles.map { title in
						Game(dataSource: _dataSource, json: title, locale: _locale)
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
