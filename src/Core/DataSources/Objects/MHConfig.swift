import Foundation

struct MHConfigTitle: Codable {
	let id: String
	let names: [String: String]
	let fullNames: [String: String]
}

struct MHConfig: Codable {
	let version: Int
	let titles: [MHConfigTitle]
}
