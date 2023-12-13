import Darwin.os.lock
import Foundation

@available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *)
public final class OSAllocatedUnfairLockBackport {
	private var unfairLock = OSAllocatedUnfairLockBackport.os_unfair_lock_make()

	deinit {
		OSAllocatedUnfairLockBackport.os_unfair_lock_free(unfairLock)
	}

	@inline(__always)
	private static func os_unfair_lock_make() -> os_unfair_lock_t {
		#if DEBUG
		if OS_LOCK_API_VERSION != 20160309 {
			fatalError("OS_LOCK_API_VERSION Changed - Revise OS_UNFAIR_LOCK_INIT implementation")
		}
		#endif

		let lock = os_unfair_lock_t.allocate(capacity: 1)
		lock.initialize(repeating: os_unfair_lock_s(), count: 1)
		return lock
	}

	@inline(__always)
	private static func os_unfair_lock_free(_ lock: os_unfair_lock_t) {
		precondition(os_unfair_lock_trylock(lock), "Unlock the lock before destroying it")
		os_unfair_lock_unlock(lock)

		lock.deinitialize(count: 1)
		lock.deallocate()
	}
}

public extension OSAllocatedUnfairLockBackport {
	@inline(__always)
	func lockIfAvailable() -> Bool { os_unfair_lock_trylock(unfairLock) }
}

// MARK: - NSLocking

extension OSAllocatedUnfairLockBackport: NSLocking {
	@inline(__always)
	public func lock() { os_unfair_lock_lock(unfairLock) }

	@inline(__always)
	public func unlock() { os_unfair_lock_unlock(unfairLock) }
}
