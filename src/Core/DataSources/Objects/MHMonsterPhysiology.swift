import Foundation

struct MHMonsterPhysiologyValue: Codable, Sendable {
	let states: [String]

	let slash: Int8
	let strike: Int8
	let shell: Int8

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
