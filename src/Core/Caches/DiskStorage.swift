import Foundation
import MessagePacker

public final class DiskStorage: Storage {
	private let fileManager: FileManager
	private let baseUrl: URL

	private lazy var decoder = MessagePackDecoder()
	private lazy var encoder = MessagePackEncoder()

	public init(fileManager: FileManager = FileManager.default) {
		self.fileManager = fileManager
		self.baseUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
	}

	public func clear() {
		try! fileManager.removeItem(at: baseUrl)
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType) -> Item? {
		load(of: type, for: key, options: StorageLoadOptions.default)
	}

	public func load<Item: Codable>(of type: Item.Type, for key: KeyType, options: StorageLoadOptions) -> Item? {
		guard let url = getFileURL(for: key, of: options.groupKey),
			  let data = try? Data(contentsOf: url) else {
			return nil
		}
		return try? decoder.decode(type, from: data)
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType) -> Bool {
		store(object, for: key, options: StorageStoreOptions.default)
	}

	@discardableResult
	public func store<Item: Codable>(_ object: Item, for key: KeyType, options: StorageStoreOptions) -> Bool {
		guard let url = getFileURL(for: key, of: options.groupKey, createDirectoryIfNotExist: true) else {
			return false
		}
		do {
			try encoder.encode(object).write(to: url)
		} catch {
			return false
		}
		return true
	}

	private func getFileURL(for key: KeyType, of groupKey: String?, createDirectoryIfNotExist: Bool = false) -> URL? {
		let url: URL
		if let groupKey = groupKey {
			if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
				url = baseUrl.appending(path: groupKey, directoryHint: .isDirectory)
			} else {
				url = baseUrl.appendingPathComponent(groupKey, isDirectory: true)
			}

			var directory: ObjCBool = false
			if !fileManager.fileExists(atPath: url.path, isDirectory: &directory) || !directory.boolValue {
				guard createDirectoryIfNotExist else {
					return nil
				}

				do {
					try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
				} catch _ as NSError {
					return nil
				}
			}
		} else {
			url = baseUrl
		}

		let fileURL: URL
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			fileURL = url.appending(path: key + ".msgpack", directoryHint: .notDirectory)
		} else {
			fileURL = url.appendingPathComponent(key + ".msgpack", isDirectory: false)
		}

		return fileURL
	}
}
