import Foundation

struct MHGameMonster: Codable, Sendable {
	let id: String
	let type: String
	let linkedID: String?
	let linkedIndex: UInt8?
	let weakness: [String: String]?

	init(id: String,
		 type: String,
		 linkedID: String? = nil,
		 linkedIndex: UInt8? = nil,
		 weakness: [String: String]? = nil) {
		self.id = id
		self.type = type
		if let linkedID, let linkedIndex {
			self.linkedID = linkedID
			self.linkedIndex = linkedIndex
		} else {
			self.linkedID = nil
			self.linkedIndex = nil
		}
		self.weakness = weakness
	}

	enum CodingKeys: CodingKey {
		case id
		case type
		case linkedId
		case linkedIndex
		case weakness
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.type = try container.decode(String.self, forKey: .type)

		let linkedID = try container.decodeIfPresent(String.self, forKey: .linkedId)
		let linkedIndex = try container.decodeIfPresent(UInt8.self, forKey: .linkedIndex)
		if let linkedID, let linkedIndex {
			self.linkedID = linkedID
			self.linkedIndex = linkedIndex
		} else {
			self.linkedID = nil
			self.linkedIndex = nil
		}

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
		try container.encodeIfPresent(self.linkedID, forKey: .linkedId)
		try container.encodeIfPresent(self.linkedIndex, forKey: .linkedIndex)
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
