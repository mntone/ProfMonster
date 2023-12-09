import Foundation
import os

public protocol Lock {
	func withLock<R>(_ body: @Sendable () throws -> R) rethrows -> R where R : Sendable
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
extension OSAllocatedUnfairLock: Lock where State == () {
}

extension OSAllocatedUnfairLockBackport: Lock {
}

public enum LockUtil {
	static func create() -> some Lock {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			return OSAllocatedUnfairLock()
		} else {
			return OSAllocatedUnfairLockBackport()
		}
	}
}
