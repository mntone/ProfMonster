import Foundation
import os.log

struct AppleLogger: Logger {
	private let logger: os.Logger = os.Logger()

	@inline(__always)
	func debug(_ message: String, file: StaticString, function: StaticString, line: UInt) {
#if DEBUG
		let filename = Self.getFilename(file)
		logger.debug("[\(filename, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)] \(message, privacy: .public)")
#endif
	}

	@inline(__always)
	func info(_ message: String, file: StaticString, function: StaticString, line: UInt) {
#if DEBUG
		let filename = Self.getFilename(file)
		logger.info("[\(filename, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)] \(message, privacy: .public)")
#else
		logger.info("[\(function, privacy: .public)] \(message, privacy: .public)")
#endif
	}

	@inline(__always)
	func notice(_ message: String, file: StaticString, function: StaticString, line: UInt) {
#if DEBUG
		let filename = Self.getFilename(file)
		logger.notice("[\(filename, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)] \(message, privacy: .public)")
#else
		logger.notice("[\(function, privacy: .public)] \(message, privacy: .public)")
#endif
	}

	@inline(__always)
	func error(_ message: String, file: StaticString, function: StaticString, line: UInt) {
#if DEBUG
		let filename = Self.getFilename(file)
		logger.error("[\(filename, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)] \(message, privacy: .public)")
#else
		logger.error("[\(function, privacy: .public)] \(message, privacy: .public)")
#endif
	}

	@inline(__always)
	func fault(_ message: String, file: StaticString, function: StaticString, line: UInt) -> Never {
#if DEBUG
		let filename = Self.getFilename(file)
		logger.fault("[\(filename, privacy: .public):\(line, privacy: .public) \(function, privacy: .public)] \(message, privacy: .public)")
#else
		logger.fault("[\(function, privacy: .public)] \(message, privacy: .public)")
#endif
		fatalError(message, file: file, line: line)
	}

#if DEBUG
	@inline(__always)
	private static func getFilename(_ file: StaticString) -> String {
		let path = URL(fileURLWithPath: "\(file)", isDirectory: false)
		let filename = path.lastPathComponent
		return filename
	}
#endif
}
