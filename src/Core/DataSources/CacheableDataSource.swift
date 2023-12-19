import Combine
import Foundation

struct CacheableDataSource {
	private let source: DataSource
	private let storage: Storage

	public init(source: DataSource, storage: Storage) {
		self.source = source
		self.storage = storage
	}
}

// MARK: - DataSource

extension CacheableDataSource: DataSource {
	private static let configKey = "conf"
	private static let gameKey = "game"
	private static let localizationKey = "i18n"
	private static let monsterKey = "mons"

	func getConfig() async throws -> MHConfig {
		guard let conf = storage.load(of: MHConfig.self, for: Self.configKey) else {
			let conf = try await source.getConfig()
			storage.store(conf, for: Self.configKey)
			return conf
		}
		return conf
	}

	func getGame(of titleId: String) async throws -> MHGame {
		let loadOptions = StorageLoadOptions(groupKey: titleId)
		guard let game = storage.load(of: MHGame.self, for: Self.gameKey, options: loadOptions) else {
			let game = try await source.getGame(of: titleId)
			let storeOptions = StorageStoreOptions(groupKey: titleId)
			storage.store(game, for: Self.gameKey, options: storeOptions)
			return game
		}
		return game
	}

	func getLocalization(of key: String, for titleId: String) async throws -> MHLocalization {
		let groupKey = "\(titleId)/\(Self.localizationKey)"
		let loadOptions = StorageLoadOptions(groupKey: groupKey)
		guard let localization = storage.load(of: MHLocalization.self, for: key, options: loadOptions) else {
			let localization = try await source.getLocalization(of: key, for: titleId)
			let storeOptions = StorageStoreOptions(groupKey: groupKey)
			storage.store(localization, for: key, options: storeOptions)
			return localization
		}
		return localization
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		let groupKey = "\(titleId)/\(Self.monsterKey)"
		let loadOptions = StorageLoadOptions(groupKey: groupKey)
		guard let monster = storage.load(of: MHMonster.self, for: id, options: loadOptions) else {
			let monster = try await source.getMonster(of: id, for: titleId)
			let storeOptions = StorageStoreOptions(groupKey: groupKey)
			storage.store(monster, for: id, options: storeOptions)
			return monster
		}
		return monster
	}
}
