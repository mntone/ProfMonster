import Combine
import Foundation

public struct MockDataSource {
	static let configTitle = MHConfigTitle(id: "mockgame", names: [
		"en": "Mock",
		"ja": "モック",
	], fullNames: [
		"en": "Mock Game",
		"ja": "モックゲーム",
	])

	static let config = MHConfig(version: 2, titles: [configTitle])

	static let localizationEnglish = MHLocalization(monsters: [
		MHLocalizationMonster(id: "gulu_qoo",
							  name: "Gulu Qoo",
							  anotherName: nil,
							  keywords: []),
		MHLocalizationMonster(id: "bucha_cat",
							  name: "Bucha Cat",
							  anotherName: nil,
							  keywords: [])
	], states: [:])

	static let localizationJapanese = MHLocalization(monsters: [
		MHLocalizationMonster(id: "gulu_qoo",
							  name: "グークー",
							  anotherName: nil,
							  keywords: []),
		MHLocalizationMonster(id: "bucha_cat",
							  name: "ブチャネコ",
							  anotherName: nil,
							  keywords: [])
	], states: [:])

	static let game = MHGame(id: "mockgame",
							 localization: ["en"],
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

	func getLocalization(of key: String, for titleId: String) async throws -> MHLocalization {
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
