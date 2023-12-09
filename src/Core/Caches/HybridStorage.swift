import Foundation

public final class HybridStorage: Storage {
	private let _memory: MemoryStorage
	private let _disk: DiskStorage

	public init() {
		self._memory = MemoryStorage()
		self._disk = DiskStorage()
	}

	public func clear() {
		_memory.clear()
		_disk.clear()
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType) -> Item? {
		load(of: type, for: key, options: StorageLoadOptions.default)
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType, options: StorageLoadOptions) -> Item? {
		if let item = _memory.load(of: type, for: key, options: options) {
			return item
		}

		guard let item = _disk.load(of: type, for: key, options: options) else {
			return nil
		}

		_memory.store(item, for: key, options: StorageStoreOptions(groupKey: options.groupKey))
		return item
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType) -> Bool {
		store(object, for: key, options: StorageStoreOptions.default)
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType, options: StorageStoreOptions) -> Bool {
		_memory.store(object, for: key, options: options)
		return _disk.store(object, for: key, options: options)
	}
}
