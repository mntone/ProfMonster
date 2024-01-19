import SwiftUI

@available(watchOS, unavailable)
struct MAHDivider: View {
	@Environment(\.pixelLength)
	private var pixelLength

	var body: some View {
		Color.formItemSeparator
			.frame(height: pixelLength)
	}
}

@available(watchOS, unavailable)
struct MAVDivider: View {
	@Environment(\.pixelLength)
	private var pixelLength

	var body: some View {
		Color.formItemSeparator
			.frame(width: pixelLength)
	}
}
