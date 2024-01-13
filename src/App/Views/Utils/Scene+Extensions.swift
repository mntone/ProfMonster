import SwiftUI

@available(watchOS, unavailable)
extension Scene {
	@SceneBuilder
	func windowResizabilityContentSize() -> some Scene {
		if #available(iOS 17.0, macOS 13.0, *) {
			windowResizability(.contentSize)
		}
	}

	@SceneBuilder
	func defaultSizeBackport(_ size: CGSize) -> some Scene {
		if #available(iOS 17.0, macOS 13.0, *) {
			defaultSize(size)
		}
	}

	@SceneBuilder
	func defaultSizeBackport(width: CGFloat, height: CGFloat) -> some Scene {
		if #available(iOS 17.0, macOS 13.0, *) {
			defaultSize(width: width, height: height)
		}
	}
}
