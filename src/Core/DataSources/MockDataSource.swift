import Combine
import Foundation

public struct MockDataSource {
	static let config = MHConfig(version: 3, games: ["mockgame"], languages: ["en", "ja"])

	static let localizationEnglish = MHLocalization(
		games: [
			MHLocalizationGame(id: "mockgame", name: "H.Fest!", fullName: "Hunster Festival!")
		],
		monsters: [
			MHLocalizationMonster(id: "gulu_qoo",
								  name: "Gulu Qoo",
								  anotherName: nil,
								  keywords: []),
			MHLocalizationMonster(id: "bucha_cat",
								  name: "Bucha Cat",
								  anotherName: nil,
								  keywords: [])
		],
		states: [:])

	static let localizationJapanese = MHLocalization(
		games: [
			MHLocalizationGame(id: "mockgame", name: "狩りカニ！", fullName: "狩り狩りカーニバル！")
		],
		monsters: [
			MHLocalizationMonster(id: "gulu_qoo",
								  name: "グークー",
								  anotherName: nil,
								  keywords: []),
			MHLocalizationMonster(id: "bucha_cat",
								  name: "ブチャネコ",
								  anotherName: nil,
								  keywords: [])
		],
		states: [:])

	static let game = MHGame(id: "mockgame",
							 copyright: nil,
							 url: nil,
							 monsters: [MHGameMonster(id: "gulu_qoo", type: "piyopiyo")])

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
		Self.game
	}

	func getLocalization(of key: String) async throws -> MHLocalization {
		if key == "ja" {
			return Self.localizationJapanese
		} else {
			return Self.localizationEnglish
		}
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		guard let key = MockMonsterKey(rawValue: id),
			  let mock = MockData.monster(key) else {
			throw StarSwingsError.notExists
		}
		return mock
	}
}
