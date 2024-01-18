import SwiftUI

struct MAItemHeader: View {
	let header: String

	var body: some View {
		Text(header)
			.font(.system(.headline))
			.accessibilityAddTraits(.isHeader)
	}
}
