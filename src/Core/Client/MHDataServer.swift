import Combine
import Foundation

public struct MHDataServer {
	private let source: MHDataSource
	private let storage: Storage

	public init(source: MHDataSource, storage: Storage) {
		self.source = source
		self.storage = storage
	}
}

// MARK: - MHDataOffer

extension MHDataServer: MHDataSource {
	private static let configKey = "conf"
	private static let gameKey = "game"
	private static let localizationKey = "i18n"
	private static let monsterKey = "mons"

	public func getConfig() -> AnyPublisher<MHConfig, Error> {
		guard let conf = storage.load(of: MHConfig.self, for: MHDataServer.configKey) else {
			return source.getConfig()
				.handleEvents(receiveOutput: { game in
					storage.store(game, for: MHDataServer.configKey)
				})
				.eraseToAnyPublisher()
		}
		return Just(conf)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	public func getGame(of titleId: String) -> AnyPublisher<MHGame, Error> {
		let loadOptions = StorageLoadOptions(groupKey: titleId)
		guard let game = storage.load(of: MHGame.self, for: MHDataServer.gameKey, options: loadOptions) else {
			return source.getGame(of: titleId)
				.handleEvents(receiveOutput: { game in
					let storeOptions = StorageStoreOptions(groupKey: titleId)
					storage.store(game, for: MHDataServer.gameKey, options: storeOptions)
				})
				.eraseToAnyPublisher()
		}
		return Just(game)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	public func getLocalization(of key: String, for titleId: String) -> AnyPublisher<MHLocalization, Error> {
		let groupKey = "\(titleId)/\(MHDataServer.localizationKey)"
		let loadOptions = StorageLoadOptions(groupKey: groupKey)
		guard let localization = storage.load(of: MHLocalization.self, for: key, options: loadOptions) else {
			return source.getLocalization(of: key, for: titleId)
				.handleEvents(receiveOutput: { localization in
					let storeOptions = StorageStoreOptions(groupKey: groupKey)
					storage.store(localization, for: key, options: storeOptions)
				})
				.eraseToAnyPublisher()
		}
		return Just(localization)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}

	public func getMonster(of id: String, for titleId: String) -> AnyPublisher<MHMonster, Error> {
		let groupKey = "\(titleId)/\(MHDataServer.monsterKey)"
		let loadOptions = StorageLoadOptions(groupKey: groupKey)
		guard let monster = storage.load(of: MHMonster.self, for: id, options: loadOptions) else {
			return source.getMonster(of: id, for: titleId)
				.handleEvents(receiveOutput: { monster in
					let storeOptions = StorageStoreOptions(groupKey: groupKey)
					storage.store(monster, for: id, options: storeOptions)
				})
				.eraseToAnyPublisher()
		}
		return Just(monster)
			.setFailureType(to: Error.self)
			.eraseToAnyPublisher()
	}
}
