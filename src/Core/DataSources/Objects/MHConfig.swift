import Foundation

struct MHConfig: Codable, Sendable {
	let version: UInt8
	let games: [String]
	let languages: [String]

	static let currentVersion: UInt8 = 3
}
