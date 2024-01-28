import SwiftUI

struct MAForm<Content: View>: View {
	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
#if os(watchOS)
		Form {
			content
		}
		.block {
			if #available(watchOS 9.0, *) {
				$0.formStyle(.grouped)
			} else {
				$0
			}
		}
		.headerProminence(.increased)
#else
		ScrollView {
			VStack(alignment: .leading, spacing: 0) {
				content

#if os(macOS)
				Color.clear.frame(height: 10.0)
#endif
			}
			.layoutMargin()
			.fixedSize(horizontal: false, vertical: true)
			.frame(maxWidth: .infinity, alignment: .leading)
		}
#if os(iOS)
		.background(Color.formBackground.ignoresSafeArea(.all, edges: .all))
#endif
#endif
	}
}
