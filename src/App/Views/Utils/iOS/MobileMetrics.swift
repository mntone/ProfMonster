#if os(iOS)

import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
public protocol MobileMetrics {
	// Use Narrow Height when Vertical Size Class is Compact.
	// 320x576 or 375x667
	var narrowNavigationBar: Bool { get }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct ErrorMobileMetrics: MobileMetrics {
	var narrowNavigationBar: Bool { fatalError() }
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
public struct DynamicMobileMetrics: MobileMetrics {
	public let narrowNavigationBar: Bool

	public init(_ window: UIWindow?) {
		if UIDevice.current.userInterfaceIdiom == .pad {
			self.narrowNavigationBar = false
		} else {
			switch UIDevice.current.model {
			case
				"iPhone8,4" /* iPhone SE (1st generation) */,
				"iPhone9,1", "iPhone9,3" /* iPhone 7 */,
				"iPhone10,1", "iPhone10,4" /* iPhone 8 */,
				"iPhone12,8" /* iPhone SE (2nd generation) */,
				"iPhone14,6" /* iPhone SE (3rd generation) */:
				self.narrowNavigationBar = true

				// Fallback unknown devices.
			default:
				let size = window?.windowScene?.screen.bounds.size ?? UIScreen.main.bounds.size
				switch (size.width, size.height) {
				case (320, 576), (576, 320), (375, 667), (667, 375):
					self.narrowNavigationBar = true
				default:
					self.narrowNavigationBar = false
				}
			}
		}
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct _MobileMetricsKey: EnvironmentKey {
	static var defaultValue: MobileMetrics {
		ErrorMobileMetrics()
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
public extension EnvironmentValues {
	var mobileMetrics: MobileMetrics {
		get { self[_MobileMetricsKey.self] }
		set { self[_MobileMetricsKey.self] = newValue }
	}
}

#endif
