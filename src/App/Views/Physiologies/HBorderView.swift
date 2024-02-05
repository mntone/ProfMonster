import SwiftUI

@available(macOS, unavailable)
struct HBorderView: View {
#if !os(watchOS)
	@Environment(\.pixelLength)
	private var pixelLength
#endif

	var body: some View {
		Color.formItemSeparator
#if os(watchOS)
			.frame(width: 0.5)
			.offset(x: -0.5)
#else
			.frame(width: pixelLength)
			.offset(x: -pixelLength)
#endif
	}
}
