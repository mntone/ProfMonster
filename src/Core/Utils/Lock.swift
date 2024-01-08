import Foundation
import struct os.OSAllocatedUnfairLock

#if VERBOSE

final class TraceableLock<BaseLock: NSLocking> {
	private let baseLock: BaseLock

	init(baseLock: BaseLock) {
		self.baseLock = baseLock
	}

	@inline(__always)
	public func lock(file: String = #file,
					 function: String = #function,
					 line: Int = #line,
					 context: Any? = nil) {
		debugPrint("LOCK: \(function) (\(file) line \(line))")
		baseLock.lock()
	}

	@inline(__always)
	public func unlock(file: String = #file,
					   function: String = #function,
					   line: Int = #line,
					   context: Any? = nil) {
		debugPrint("UNLOCK: \(function) (\(file) line \(line))")
		baseLock.unlock()
	}

	public func withLock<R>(_ body: @Sendable () throws -> R,
							file: String = #file,
							function: String = #function,
							line: Int = #line,
							context: Any? = nil) rethrows -> R where R : Sendable {
		defer { unlock(file: file, function: function, line: line, context: context) }
		lock(function: function, line: line, context: context)
		return try body()
	}
}

typealias Lock = TraceableLock<OSAllocatedUnfairLockBackport>

#else

protocol Lock {
	func withLock<R>(_ body: @Sendable () throws -> R) rethrows -> R where R : Sendable
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
extension OSAllocatedUnfairLock: Lock where State == () {
}

extension OSAllocatedUnfairLockBackport: Lock {
}

#endif

enum LockUtil {
	static func create() -> some Lock {
#if VERBOSE
		return TraceableLock(baseLock: OSAllocatedUnfairLockBackport())
#else
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			return OSAllocatedUnfairLock()
		} else {
			return OSAllocatedUnfairLockBackport()
		}
#endif
	}
}
