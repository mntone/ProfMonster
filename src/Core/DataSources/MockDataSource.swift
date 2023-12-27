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

	static let localization = MHLocalization(monsters: [
		MHLocalizationMonster(id: "gulu_qoo",
							  name: "Gulu Qoo",
							  anotherName: nil,
							  keywords: [])
	], states: [:])

	static let game = MHGame(id: "mockgame",
							 localization: ["en"],
							 monsters: [MHGameMonster(id: "gulu_qoo", type: "piyopiyo")])

	public static let monster1 = MHMonster(id: "gulu_qoo",
										   type: "piyopiyo",
										   version: "1.0.0",
										   physiologies: [
			MHMonsterPhysiology(
			   parts: ["head"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 68,
					   strike: 68,
					   shell: 60,
					   fire: 15,
					   water: 20,
					   thunder: 15,
					   ice: 15,
					   dragon: 15,
					   stun: 100),
			   ]
		   ),
		   MHMonsterPhysiology(
			   parts: ["torso"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 45,
					   strike: 45,
					   shell: 40,
					   fire: 15,
					   water: 20,
					   thunder: 15,
					   ice: 15,
					   dragon: 15,
					   stun: 0),
			   ]
		   ),
		   MHMonsterPhysiology(
			   parts: ["foreleg"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 52,
					   strike: 56,
					   shell: 45,
					   fire: 15,
					   water: 20,
					   thunder: 15,
					   ice: 15,
					   dragon: 10,
					   stun: 0),
			   ]
		   ),
		   MHMonsterPhysiology(
			   parts: ["tail"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 55,
					   strike: 50,
					   shell: 35,
					   fire: 15,
					   water: 20,
					   thunder: 15,
					   ice: 15,
					   dragon: 15,
					   stun: 0),
			   ]
		   ),
		   MHMonsterPhysiology(
			   parts: ["boulder"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 5,
					   strike: 5,
					   shell: 5,
					   fire: 5,
					   water: 20,
					   thunder: 5,
					   ice: 5,
					   dragon: 5,
					   stun: 0),
			   ]
		   ),
		   MHMonsterPhysiology(
			   parts: ["pod"],
			   values: [
				   MHMonsterPhysiologyValue(
					   states: ["default"],
					   slash: 50,
					   strike: 50,
					   shell: 50,
					   fire: 15,
					   water: 20,
					   thunder: 15,
					   ice: 15,
					   dragon: 15,
					   stun: 0),
			   ]
		   ),
	   ])

	public static var physiology1: Physiologies {
		let mapper = PhysiologyMapper(languageService: PassthroughtLanguageService())
		return mapper.map(json: monster1, options: PhysiologyMapperOptions(mergeParts: false))
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
		Self.localization
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		Self.monster1
	}
}
