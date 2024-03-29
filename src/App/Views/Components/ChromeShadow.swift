import SwiftUI

@available(watchOS, unavailable)
struct ChromeShadow: View {
	@Environment(\.pixelLength)
	private var pixelLength

	var body: some View {
		Color.chromeShadow
			.frame(height: pixelLength)
			.offset(y: pixelLength)
	}
}
