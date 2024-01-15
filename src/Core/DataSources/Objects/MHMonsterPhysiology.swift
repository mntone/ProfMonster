import Foundation

struct MHMonsterPhysiologyValue: Codable, Sendable {
	let states: [String]

	let slash: Int8
	let impact: Int8
	let shot: Int8

	let fire: Int8
	let water: Int8
	let thunder: Int8
	let ice: Int8
	let dragon: Int8

	let stun: Int8
}

struct MHMonsterPhysiology: Codable, Sendable {
	let parts: [String]
	let values: [MHMonsterPhysiologyValue]
}
