import Foundation

public struct MHMonster: Codable {
	let id: String
	let version: String
	let physiologies: [MHMonsterPhysiology]
}
