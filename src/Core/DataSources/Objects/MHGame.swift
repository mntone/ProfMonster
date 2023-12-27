import Foundation

struct MHGame: Codable, Sendable {
	let id: String
	let localization: [String]
	let monsters: [String]
}
