import Foundation

public struct MHMonster: Codable {
	public let id: String
	public let version: String
	public let physiologies: [MHMonsterPhysiology]

	public static func getMock() -> MHMonster {
		MHMonster(id: "mock", version: "1.0.0", physiologies: [
			MHMonsterPhysiology(
				parts: ["head"],
				values: [
					MHMonsterPhysiologyValue(
						state: "default",
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
						state: "default",
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
						state: "default",
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
						state: "default",
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
						state: "default",
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
						state: "default",
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
	}
}
