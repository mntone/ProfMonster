import SwiftUI

struct HBorderView: View {
	@Environment(\.pixelLength)
	private var pixelLength

	var body: some View {
		Color.separator
			.frame(width: pixelLength)
			.offset(x: -pixelLength)
	}
}
