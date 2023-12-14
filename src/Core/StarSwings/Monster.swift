import Combine
import Foundation

public final class Monster: FetchableEntity, Entity {
	public let id: String
	public let gameID: String
	public let name: String
	public let anotherName: String?
	public let keywords: [String]

	@Published
	public var data: MHMonster?

	private var _cancellable: AnyCancellable?

	init(_ id: String,
		 gameID: String,
		 dataSource: MHDataSource,
		 localization: MHLocalizationMonster) {
		self.id = id
		self.gameID = gameID
		self.name = localization.name
		self.anotherName = localization.anotherName
		self.keywords = localization.getAllKeywords()
		super.init(dataSource: dataSource)
	}

	public func fetchIfNeeded() {
		_lock.withLock {
			guard case .ready = state else { return }
			state = .loading

			_dataSource.getMonster(of: id, for: gameID)
				.map(Optional.init)
				.catch { error in
					self._handle(error: error)
					return Empty<MHMonster?, Never>()
				}
				.handleEvents(receiveCompletion: { completion in
					if case .finished = completion {
						self.state = .complete
					}
				})
				.assign(to: &$data)
		}
	}
}
