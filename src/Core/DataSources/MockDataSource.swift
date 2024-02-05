import Foundation

public struct MockDataSource {
	static let config = MHConfig(version: 3, games: ["mockgame"], languages: ["en", "ja"], source: nil)

	public static var physiology1: Physiologies {
		let monster = MockData.monster(.guluQoo)!
		let mapper = PhysiologyMapper(languageService: PassthroughtLanguageService())
		return mapper.map(json: monster, options: PhysiologyMapperOptions(mergeParts: false))
	}

	public init() {
	}
}

// MARK: - DataSource

extension MockDataSource: DataSource {
	func getConfig() async throws -> MHConfig {
		Self.config
	}

	func getGame(of titleId: String) async throws -> MHGame {
		guard let mock = MockData.game() else {
			throw StarSwingsError.notExists
		}
		return mock
	}

	func getLocalization(of key: String) async throws -> MHLocalization {
		guard let mock = MockData.localization(key) else {
			throw StarSwingsError.notExists
		}
		return mock
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		guard let key = MockMonsterKey(rawValue: id) else {
			guard let fallbackMock = MockData.monster(.guluQoo) else {
				throw StarSwingsError.notExists
			}
			// Return default monster as fallback.
			return fallbackMock
		}

		guard let mock = MockData.monster(key) else {
			throw StarSwingsError.notExists
		}
		return mock
	}
}
