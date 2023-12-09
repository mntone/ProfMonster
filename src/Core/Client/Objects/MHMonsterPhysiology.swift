import Foundation

public struct MHMonsterPhysiologyValue: Codable {
	public let state: String

	public let slash: Int8
	public let strike: Int8
	public let shell: Int8

	public let fire: Int8
	public let water: Int8
	public let thunder: Int8
	public let ice: Int8
	public let dragon: Int8

	public let stun: Int8
}

public struct MHMonsterPhysiology: Codable {
	public let parts: [String]
	public let values: [MHMonsterPhysiologyValue]
}
