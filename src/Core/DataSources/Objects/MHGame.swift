import Foundation

struct MHGameMonster: Codable, Sendable {
	let id: String
	let type: String
	let weakness: [String: String]?

	init(id: String, type: String, weakness: [String: String]? = nil) {
		self.id = id
		self.type = type
		self.weakness = weakness
	}

	enum CodingKeys: CodingKey {
		case id
		case type
		case weakness
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.type = try container.decode(String.self, forKey: .type)

		if let weakness = try? container.decode([String: String].self, forKey: .weakness) {
			self.weakness = weakness
		} else if let defaultWeakness = try? container.decode(String.self, forKey: .weakness) {
			self.weakness = ["default": defaultWeakness]
		} else {
			self.weakness = nil
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.type, forKey: .type)
		if let weakness = self.weakness,
		   weakness.count == 1,
		   let defaultValue = weakness["default"] {
			try container.encode(defaultValue, forKey: .weakness)
		} else {
			try container.encode(self.weakness, forKey: .weakness)
		}
	}
}

struct MHGame: Codable, Sendable {
	let id: String
	let localization: [String]
	let monsters: [MHGameMonster]
}
