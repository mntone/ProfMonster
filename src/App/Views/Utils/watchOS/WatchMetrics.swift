import Foundation
import SwiftUI
import WatchKit

public enum Bezel {
	case square
	case round
}

// ref. https://developer.apple.com/documentation/watchos-apps/supporting-multiple-watch-sizes/
public protocol WatchMetrics {
	var device: WatchDevice { get }
	var bezel: Bezel { get }
	var width: CGFloat { get }
	var height: CGFloat { get }
	var imageScale: CGFloat { get }
	var iconSize: CGFloat { get }
	var topCircularButtonLength: CGFloat { get } // 2 * round(15 * imageScale)

	var safeAreaInsets: EdgeInsets { get }
	var preferredSafeAreaInsets: EdgeInsets { get }
}

fileprivate protocol WatchMetricsPrivate {
	var safeAreaInsets3: EdgeInsets { get } // watchOS 8
	var safeAreaInsets5: EdgeInsets { get } // watchOS 10
}

extension WatchMetricsPrivate {
	public var safeAreaInsets: EdgeInsets {
		safeAreaInsets5
	}

	public var preferredSafeAreaInsets: EdgeInsets {
		if #available(watchOS 10.0, *) {
			safeAreaInsets5
		} else {
			safeAreaInsets3
		}
	}
}

struct ErrorWatchMetrics: WatchMetrics, WatchMetricsPrivate {
	var device: WatchDevice { fatalError() }
	var bezel: Bezel { fatalError() }
	var width: CGFloat { fatalError() }
	var height: CGFloat { fatalError() }
	var imageScale: CGFloat { fatalError() }
	var iconSize: CGFloat { fatalError() }
	var topCircularButtonLength: CGFloat { fatalError() }

	fileprivate var safeAreaInsets3: EdgeInsets { fatalError() }
	fileprivate var safeAreaInsets5: EdgeInsets { fatalError() }
}

public struct DynamicWatchMetrics: WatchMetrics, WatchMetricsPrivate {
	public let device: WatchDevice = .unknown
	public let bezel: Bezel = .square
	public let width: CGFloat
	public let height: CGFloat
	public let imageScale: CGFloat
	public let iconSize: CGFloat = 40
	public let topCircularButtonLength: CGFloat

	public let safeAreaInsets3: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
	public let safeAreaInsets5: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)

	public init(size: CGSize) {
		self.width = size.width
		self.height = size.height
		self.imageScale = max(0.9, min(0.01 * round(100 * size.height / 203), 1.19))
		self.topCircularButtonLength = 2 * round(15 * imageScale)
	}
}

private struct Case38WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case38
	let bezel: Bezel = .square
	let width: CGFloat = 136
	let height: CGFloat = 170
	let imageScale: CGFloat = 0.9
	let iconSize: CGFloat = 40
	let topCircularButtonLength: CGFloat = 27

	public let safeAreaInsets3: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
	public let safeAreaInsets5: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
}

private struct Case42WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case42
	let bezel: Bezel = .square
	let width: CGFloat = 156
	let height: CGFloat = 195
	let imageScale: CGFloat = 1
	let iconSize: CGFloat = 40
	let topCircularButtonLength: CGFloat = 30

	public let safeAreaInsets3: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
	public let safeAreaInsets5: EdgeInsets = .init(top: 0.0, leading: 1.0, bottom: 0.0, trailing: 1.0)
}

private struct Case40WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case40
	let bezel: Bezel = .round
	let width: CGFloat = 162
	let height: CGFloat = 197
	let imageScale: CGFloat = 1
	let iconSize: CGFloat = 44
	let topCircularButtonLength: CGFloat = 30

	let safeAreaInsets3: EdgeInsets = .init(top: 28.0, leading: 8.5, bottom: 9.0, trailing: 8.5)
	let safeAreaInsets5: EdgeInsets = .init(top: 10.0, leading: 9.5, bottom: 10.0, trailing: 9.5)
}

private struct Case44WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case44
	let bezel: Bezel = .round
	let width: CGFloat = 184
	let height: CGFloat = 224
	let imageScale: CGFloat = 1.1
	let iconSize: CGFloat = 50
	let topCircularButtonLength: CGFloat = 34

	let safeAreaInsets3: EdgeInsets = .init(top: 31.0, leading: 9.5, bottom: 11.0, trailing: 9.5)
	let safeAreaInsets5: EdgeInsets = .init(top: 12.5, leading: 10.5, bottom: 12.5, trailing: 10.5)
}

@available(watchOS 8.0, *)
private struct Case41WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case41
	let bezel: Bezel = .round
	let width: CGFloat = 176
	let height: CGFloat = 215
	let imageScale: CGFloat = 1.06
	let iconSize: CGFloat = 46
	let topCircularButtonLength: CGFloat = 32

	let safeAreaInsets3: EdgeInsets = .init(top: 34.0, leading: 11.0, bottom: 14.0, trailing: 11.0)
	let safeAreaInsets5: EdgeInsets = .init(top: 14.0, leading: 11.5, bottom: 14.0, trailing: 11.5)
}

@available(watchOS 8.0, *)
private struct Case45WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case45
	let bezel: Bezel = .round
	let width: CGFloat = 198
	let height: CGFloat = 242
	let imageScale: CGFloat = 1.19
	let iconSize: CGFloat = 51
	let topCircularButtonLength: CGFloat = 36

	let safeAreaInsets3: EdgeInsets = .init(top: 35.0, leading: 12.0, bottom: 16.0, trailing: 12.0)
	let safeAreaInsets5: EdgeInsets = .init(top: 15.0, leading: 12.5, bottom: 15.0, trailing: 12.5)
}

@available(watchOS 9.0, *)
private struct Case49WatchMetrics: WatchMetrics, WatchMetricsPrivate {
	let device: WatchDevice = .case49
	let bezel: Bezel = .round
	let width: CGFloat = 205
	let height: CGFloat = 251
	let imageScale: CGFloat = 1.19
	let iconSize: CGFloat = 54
	let topCircularButtonLength: CGFloat = 36

	let safeAreaInsets3: EdgeInsets = .init(top: 37.0, leading: 14.0, bottom: 18.5, trailing: 14.0)
	let safeAreaInsets5: EdgeInsets = .init(top: 19.0, leading: 15.5, bottom: 15.0, trailing: 15.5)
}

public extension WatchUtil {
	static func getMetrics(from size: CGSize) -> WatchMetrics {
		switch size {
		case CGSize(width: 205, height: 251):
			if #available(watchOS 9.0, *) {
				return Case49WatchMetrics()
			} else {
				fallthrough
			}
		case CGSize(width: 176, height: 215):
			return Case41WatchMetrics()
		case CGSize(width: 198, height: 242):
			return Case45WatchMetrics()
		case CGSize(width: 162, height: 197):
			return Case40WatchMetrics()
		case CGSize(width: 184, height: 224):
			return Case44WatchMetrics()
		case CGSize(width: 136, height: 170):
			return Case38WatchMetrics()
		case CGSize(width: 156, height: 195):
			return Case42WatchMetrics()
		default:
			return DynamicWatchMetrics(size: size)
		}
	}

	static func getMetrics() -> WatchMetrics {
		let size = WKInterfaceDevice.current().screenBounds.size
		return getMetrics(from: size)
	}
}
