import Combine

public struct UDMonster {
	public let id: String
	public var isFavorited: Bool
	public var note: String

	init(coreData: CDMonster) {
		self.id = coreData.id!
		self.isFavorited = coreData.isFavorited
		self.note = coreData.note ?? ""
	}

	public init(id: String, isFavorited: Bool, note: String) {
		self.id = id
		self.isFavorited = isFavorited
		self.note = note
	}
}
