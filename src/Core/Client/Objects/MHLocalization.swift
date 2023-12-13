import Foundation

public struct MHLocalizationMonster: Codable {
	public let id: String
	public let name: String
	public let anotherName: String?
	public let keywords: [String]
	
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
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.name = try container.decode(String.self, forKey: .name)
		self.anotherName = try container.decodeIfPresent(String.self, forKey: .anotherName)
		self.keywords = try container.decodeIfPresent([String].self, forKey: .keywords) ?? []
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(name, forKey: .name)
		try container.encodeIfPresent(anotherName, forKey: .anotherName)
		if !keywords.isEmpty {
			try container.encode(keywords, forKey: .keywords)
		}
	}
}

public struct MHLocalization: Codable {
	public let monsters: [MHLocalizationMonster]
}
