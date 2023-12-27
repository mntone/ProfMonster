import Foundation

struct MHConfigTitle: Codable, Sendable {
	let id: String
	let names: [String: String]
	let fullNames: [String: String]
}

struct MHConfig: Codable, Sendable {
	let version: UInt8
	let titles: [MHConfigTitle]

	static let currentVersion: UInt8 = 1
}
