import Foundation

struct MHLocalizationMonster: Codable, Sendable {
	let id: String
	let name: String
	let anotherName: String?
	let keywords: [String]

	init(id: String,
		 name: String,
		 anotherName: String? = nil,
		 keywords: [String] = []) {
		self.id = id
		self.name = name
		self.anotherName = anotherName
		self.keywords = keywords
	}

	private enum CodingKeys: CodingKey {
		case id
		case name
		case anotherName
		case keywords
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.anotherName = try container.decodeIfPresent(String.self, forKey: .anotherName)
		self.keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(anotherName, forKey: .anotherName)
		if !keywords.isEmpty {
			try container.encode(keywords, forKey: .keywords)
		}
	}
}

struct MHLocalization: Codable, Sendable {
	let monsters: [MHLocalizationMonster]
	let states: [String: String]

	init(monsters: [MHLocalizationMonster],
		 states: [String: String]) {
		self.monsters = monsters
		self.states = states
	}

	private enum CodingKeys: CodingKey {
		case monsters
		case states
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.monsters = try container.decode([MHLocalizationMonster].self, forKey: .monsters)
		self.states = try container.decodeIfPresent([String: String].self, forKey: .states) ?? [:]
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.monsters, forKey: .monsters)
		if !states.isEmpty {
			try container.encode(self.states, forKey: .states)
		}
	}
}
