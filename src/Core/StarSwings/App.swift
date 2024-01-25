import Foundation
import class Swinject.Container
import protocol Swinject.Resolver

public final class App: FetchableEntity<[Game]>, Entity {
	private let _container: Container
	private let _resolver: Resolver
	private let _storage: Storage
#if os(iOS)
	private let _pad: Bool
#endif

	public let logger: Logger
	public let sourceURL: URL
	public let isUserSource: Bool
	public let settings = Settings()

	public private(set) var languageService: LanguageService?

	private var requireReinitApp: Bool = false

	public init(container: Container, pad: Bool) {
		guard let logger = container.resolve(Logger.self) else {
			fatalError("Failed to get Logger.")
		}
		guard let storage = container.resolve(Storage.self) else {
			logger.fault("Failed to get Storage.")
		}

		let settingsSource = settings.source
		if !settingsSource.isEmpty,
		   let userSourceURL = URL(string: settingsSource) {
			self.sourceURL = userSourceURL
			self.isUserSource = true
		} else {
			self.sourceURL = AppUtil.dataSourceURL
			self.isUserSource = false
		}
		guard let dataSource = container.resolve(DataSource.self, argument: sourceURL) else {
			logger.fault("Failed to get DataSource.")
		}

		self._container = container
		self._resolver = container.synchronize()
		self._storage = storage
#if os(iOS)
		self._pad = pad
#endif
		self.logger = logger
#if DEBUG
		super.init(dataSource: dataSource, delayed: settings.delayNetworkRequest)
#else
		super.init(dataSource: dataSource)
#endif
	}

	public func getCacheSize() async -> UInt64? {
		await Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return nil }
			return self._storage.size
		}.value
	}

	public func changeSourceURL(_ sourceURLString: String) {
		self.logger.notice("Change data source.")
		requireReinitApp = true
		Task {
			await resetAllData().value
			_container.resetObjectScope(.container)
			if sourceURLString == AppUtil.dataSourceURL.absoluteString {
				settings.source = ""
			} else {
				settings.source = sourceURLString
			}
		}
	}

	@discardableResult
	public func resetAllData() -> Task<Void, Never> {
		Task.detached(priority: .utility) { [weak self] in
			guard let self else { return }
			self.logger.notice("Reset all data.")
			self._storage.resetAll()
			self.resetState()
		}
	}

	public func resetMemoryData() {
		self.logger.notice("Reset memory cache from user operation.")
		self.resetState()
	}

	@discardableResult
	public func resetAllSettings() -> Task<Void, Never> {
		Task.detached(priority: .utility) { [weak self] in
			guard let self else { return }
			guard let appDomain = Bundle.main.bundleIdentifier else {
				self.logger.error("Failed to get the bundle indentifier.")
				return
			}
			self.logger.notice("Reset all settings.")
			UserDefaults.standard.removePersistentDomain(forName: appDomain)
		}
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
		guard !requireReinitApp else {
			throw StarSwingsError.cancelled
		}

		let config = try await _dataSource.getConfig()

		// Check data format version.
		guard config.version == MHConfig.currentVersion else {
			throw StarSwingsError.notSupported
		}

		// Get localization.
		let preferredLocaleKey = LanguageUtil.getPreferredLanguageKey(config.languages)
		let localization = try await _dataSource.getLocalization(of: preferredLocaleKey)

		// Inititalize LanguageService.
		let langsvc = _resolver.resolve(LanguageServiceInternal.self, arguments: preferredLocaleKey, localization)!
		self.languageService = langsvc

		// Inititalize mappers.
#if os(iOS)
		let resourceMapper = MonsterResourceMapper(languageService: langsvc, pad: _pad)
#else
		let resourceMapper = MonsterResourceMapper(languageService: langsvc)
#endif
		let physiologyMapper = PhysiologyMapper(languageService: langsvc)

		let games = config.games.map { gameID in
			Game(app: self,
				 resolver: _resolver,
				 dataSource: _dataSource,
				 logger: logger,
				 resourceMapper: resourceMapper,
				 physiologyMapper: physiologyMapper,
				 id: gameID,
				 localization: localization.games.first(where: { g in g.id == gameID })!)
		}
		return games
	}

	override func _resetChildStates() {
		if var games = state.data {
			games.forEach { game in
				game.resetState()
			}
			games.removeAll()
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
