import Foundation

#if os(macOS)
import class AppKit.NSApplication
#elseif os(watchOS)
import class WatchKit.WKApplication
#else
import class UIKit.UIApplication
#endif

public extension Notification.Name {
	static var platformWillResignActiveNotification: Notification.Name {
#if os(macOS)
		NSApplication.willResignActiveNotification
#elseif os(watchOS)
		if #available(watchOS 9.0, *) {
			WKApplication.willResignActiveNotification
		} else {
			// Fixes an issue of "Symbol not found" on watchOS 8.5 (maybe, all watchOS 8.x)
			Notification.Name("WKApplicationWillResignActiveNotification")
		}
#else
		UIApplication.willResignActiveNotification
#endif
	}

	static var platformDidEnterBackgroundNotification: Notification.Name {
#if os(macOS)
		NSApplication.didResignActiveNotification
#elseif os(watchOS)
		if #available(watchOS 9.0, *) {
			WKApplication.didEnterBackgroundNotification
		} else {
			// Fixes an issue of "Symbol not found" on watchOS 8.5 (maybe, all watchOS 8.x)
			Notification.Name("WKApplicationDidEnterBackgroundNotification")
		}
#else
		UIApplication.didEnterBackgroundNotification
#endif
	}
}
