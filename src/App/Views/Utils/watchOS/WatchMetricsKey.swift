import Foundation
import SwiftUI

public struct WatchMetricsKey: EnvironmentKey {
	public static var defaultValue: WatchMetrics {
		ErrorWatchMetrics()
	}
}

public extension EnvironmentValues {
	var watchMetrics: WatchMetrics {
		get { self[WatchMetricsKey.self] }
		set { self[WatchMetricsKey.self] = newValue }
	}
}
