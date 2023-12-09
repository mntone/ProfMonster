import SwiftUI

#if os(watchOS)
import WatchKit
#endif

struct HBorderView: View {
#if os(macOS)
	static let length: CGFloat = 1
#elseif os(watchOS)
	static let length: CGFloat = 1 / WKInterfaceDevice.current().screenScale
#else
	static let length: CGFloat = 1 / UIScreen.main.scale
#endif

	var body: some View {
		Color.separator.frame(width: HBorderView.length)
	}
}
