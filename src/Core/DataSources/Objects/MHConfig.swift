import Foundation

public struct MHDataSourceInformation: Codable, Sendable {
	public let name: String
	public let copyright: String
	public let license: String
}

struct MHConfig: Codable, Sendable {
	let version: UInt8
	let games: [String]
	let languages: [String]
	let source: MHDataSourceInformation?

	static let currentVersion: UInt8 = 3
}
