#if os(iOS) || os(watchOS)

import SwiftUI

@available(macOS, unavailable)
struct HBorderView: View {
	@Environment(\.pixelLength)
	private var pixelLength

	var body: some View {
		Color.formItemSeparator
			.frame(width: pixelLength)
			.offset(x: -pixelLength)
	}
}

#endif
