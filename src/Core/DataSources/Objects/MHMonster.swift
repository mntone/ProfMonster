import Foundation

public struct MHMonster: Codable, Sendable {
	let id: String
	let version: String
	let physiologies: [MHMonsterPhysiology]
}
