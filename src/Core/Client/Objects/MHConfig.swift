import Foundation

public struct MHConfigTitle: Codable {
	public let id: String
	public let names: [String: String]
	public let fullNames: [String: String]
}

public struct MHConfig: Codable {
	public let version: Int
	public let titles: [MHConfigTitle]
}
