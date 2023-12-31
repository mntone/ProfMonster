import Foundation

struct MHMonster: Codable, Sendable {
	let id: String
	let type: String
	let version: String
	let physiologies: [MHMonsterPhysiology]
}
