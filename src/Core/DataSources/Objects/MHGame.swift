import Foundation

struct MHGameMonster: Codable, Sendable {
	let id: String
	let type: String
}

struct MHGame: Codable, Sendable {
	let id: String
	let localization: [String]
	let monsters: [MHGameMonster]
}
