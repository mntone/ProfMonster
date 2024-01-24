import SwiftUI

extension View {
	@inline(__always)
	@ViewBuilder
	func onWidthChange(perform: @escaping (CGFloat) -> Void) -> some View {
		background(WidthObserver(perform: perform))
	}

	@inline(__always)
	@ViewBuilder
	func onHeightChange(perform: @escaping (CGFloat) -> Void) -> some View {
		background(HeightObserver(perform: perform))
	}
}
