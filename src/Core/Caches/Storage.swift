import Foundation

public struct StorageLoadOptions {
	public let autoExtendExpire: Bool
	public let groupKey: String?

	init(autoExtendExpire: Bool = true,
		 groupKey: String? = nil) {
		self.autoExtendExpire = autoExtendExpire
		self.groupKey = groupKey
	}

	public static let `default` = StorageLoadOptions(autoExtendExpire: true, groupKey: nil)
}

public struct StorageStoreOptions {
	public let groupKey: String?

	public static let `default` = StorageStoreOptions(groupKey: nil)
}

public protocol Storage {
	typealias KeyType = String

	func clear()

	func load<Item: Codable>(of type: Item.Type, for key: KeyType) -> Item?
	func load<Item: Codable>(of type: Item.Type, for key: KeyType, options: StorageLoadOptions) -> Item?

	@discardableResult
	func store<Item: Codable>(_ object: Item, for key: KeyType) -> Bool
	@discardableResult
	func store<Item: Codable>(_ object: Item, for key: KeyType, options: StorageStoreOptions) -> Bool
}
