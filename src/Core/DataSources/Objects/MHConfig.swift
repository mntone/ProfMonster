import Foundation

struct MHConfigTitle: Codable {
	let id: String
	let names: [String: String]
	let fullNames: [String: String]
}

struct MHConfig: Codable {
	let version: UInt8
	let titles: [MHConfigTitle]

	static let currentVersion: UInt8 = 1
}
