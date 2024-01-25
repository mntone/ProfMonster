import Foundation
import MessagePacker

final class DiskStorage: Storage {
	private let fileManager: FileManager
	private let logger: Logger
	private let baseUrl: URL

	init(fileManager: FileManager = FileManager.default, logger: Logger) {
		self.fileManager = fileManager
		self.logger = logger
		self.baseUrl = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
	}

	var measureMode: StorageSizeMeasureMode {
		@inline(__always)
		get {
			.actual
		}
	}

	var size: UInt64 {
		getSize(at: baseUrl)
	}

	private func getSize(at baseUrl: URL) -> UInt64 {
		do {
			return try fileManager.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil).reduce(into: UInt64(0)) { size, url in
#if os(macOS) || targetEnvironment(simulator)
				guard !Self.isExclude(url.lastPathComponent) else {
					return
				}
#endif

				do {
					let itemAttributes = try fileManager.attributesOfItem(atPath: url.relativePath)
					if itemAttributes[.type] as! FileAttributeType == FileAttributeType.typeDirectory {
						size += getSize(at: url)
					} else {
						size += itemAttributes[.size] as! UInt64  // an NSNumber object containing an unsigned long long
					}
				} catch {
					// No action; maybe, file is not found.
				}
			}
		} catch {
			// Not found
			return 0
		}
	}

	func resetAll() {
		do {
			try fileManager.contentsOfDirectory(at: baseUrl, includingPropertiesForKeys: nil).forEach { url in
#if os(macOS) || targetEnvironment(simulator)
				guard !Self.isExclude(url.lastPathComponent) else {
					return
				}
#endif

				do {
					try fileManager.removeItem(at: url)
				} catch {
					logger.error("Failed to delete \"\(url.lastPathComponent)\".")
				}
			}
		} catch {
			logger.error("Failed to retrieve items.")
		}
	}

	@inline(__always)
	func load<Item: Codable>(of type: Item.Type, for key: KeyType) -> Item? {
		load(of: type, for: key, options: StorageLoadOptions.default)
	}

	func load<Item: Codable>(of type: Item.Type, for key: KeyType, options: StorageLoadOptions) -> Item? {
		guard let url = getFileURL(for: key, of: options.groupKey),
			  let data = try? Data(contentsOf: url) else {
			return nil
		}

		let decoder = MessagePackDecoder()
		return try? decoder.decode(type, from: data)
	}

	@discardableResult
	@inline(__always)
	func store<Item: Codable>(_ object: Item, for key: KeyType) -> Bool {
		store(object, for: key, options: StorageStoreOptions.default)
	}

	@discardableResult
	func store<Item: Codable>(_ object: Item, for key: KeyType, options: StorageStoreOptions) -> Bool {
		guard let url = getFileURL(for: key, of: options.groupKey, createDirectoryIfNotExist: true) else {
			return false
		}

		let encoder = MessagePackEncoder()
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

#if os(macOS) || targetEnvironment(simulator)
	private static func isExclude(_ name: String) -> Bool {
		switch name {
#if os(macOS)
		case ".DS_Store", "CloudKit":
			true
#elseif targetEnvironment(simulator)
		case ".DS_Store":
			true
#endif
		default:
			false
		}
	}
#endif
}
