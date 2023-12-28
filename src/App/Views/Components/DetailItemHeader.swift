import SwiftUI

struct DetailItemHeader: View {
	let header: String

	var body: some View {
		Text(verbatim: header)
			.font(.system(.subheadline).weight(.medium))
			.accessibilityAddTraits(.isHeader)
	}
}
