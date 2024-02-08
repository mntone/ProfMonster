import Foundation

struct MHMonsterState: Codable, Sendable {
	let id: String
	let parentState: String?

	init(id: String, parentState: String?) {
		self.id = id
		self.parentState = parentState
	}

	enum CodingKeys: CodingKey {
		case id
		case parentState
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		do {
			self.parentState = try container.decode(String.self, forKey: .parentState)
		} catch {
			self.parentState = "default"
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		if self.parentState != "default" {
			try container.encode(self.parentState, forKey: .parentState)
		}
	}
}

struct MHMonster: Codable, Sendable {
	let id: String
	let type: String
	let version: String
	let defaultMode: String?
	let physiologies: [MHMonsterPhysiology]
	let states: [MHMonsterState]?
}
