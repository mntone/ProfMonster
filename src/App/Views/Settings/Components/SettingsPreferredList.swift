import SwiftUI

struct SettingsPreferredList<Content: View>: View {
	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
#if os(iOS)
		List {
			content
#if os(iOS)
				.listRowInsetsLayoutMargin()
#endif
		}
#else
		Form {
			content
		}
#endif
	}
}
