import Foundation

public struct MHLocalizationMonster: Codable {
	public let id: String
	public let name: String
}

public struct MHLocalization: Codable {
	public let monsters: [MHLocalizationMonster]
}
