import Foundation

public final class MemoryStorage: Storage {
	private static let defaultGroupKey = "_def"

	private let _lock: any Lock
	private var _cache: [String: [String: any Codable]]

	public init() {
		self._lock = LockUtil.create()
		self._cache = [MemoryStorage.defaultGroupKey: [:]]
	}

	public func clear() {
		_lock.withLock {
			_cache = [MemoryStorage.defaultGroupKey: [:]]
		}
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType) -> Item? {
		load(of: type, for: key, options: StorageLoadOptions.default)
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType, options: StorageLoadOptions) -> Item? {
		let groupKey = options.groupKey ?? MemoryStorage.defaultGroupKey
		return _lock.withLock {
			guard let groupCache = _cache[groupKey] else {
				return nil
			}
			return groupCache[key] as? Item
		}
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType) -> Bool {
		store(object, for: key, options: StorageStoreOptions.default)
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType, options: StorageStoreOptions) -> Bool {
		let groupKey = options.groupKey ?? MemoryStorage.defaultGroupKey
		_lock.withLock {
			if _cache.keys.contains(groupKey) {
				_cache[groupKey]![key] = object
			} else {
				let newTarget: [String: any Codable] = [key: object]
				_cache[groupKey] = newTarget
			}
		}
		return true
	}
}
