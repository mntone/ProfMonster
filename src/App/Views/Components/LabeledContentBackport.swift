import SwiftUI

struct LabeledContentBackport<Content: View>: View {
	let title: LocalizedStringKey
	let content: Content

	init(_ title: LocalizedStringKey, @ViewBuilder content: @escaping () -> Content) {
		self.title = title
		self.content = content()
	}

	var body: some View {
#if os(watchOS)
		VStack(alignment: .leading) {
			Text(title)
			content.foregroundStyle(.secondary)
		}
		.multilineTextAlignment(.leading)
#else
		HStack(alignment: .firstTextBaseline) {
			Text(title)
			Spacer()
			content.foregroundStyle(.secondary)
		}
#endif
	}
}

extension LabeledContentBackport where Content == Text {
	init(_ title: LocalizedStringKey, value: String) {
		self.title = title
		self.content = Text(verbatim: value)
	}

	init(_ title: LocalizedStringKey, value: LocalizedStringKey) {
		self.title = title
		self.content = Text(value)
	}
}
