import SwiftUI

struct LabeledContentBackport<Content: View>: View {
	let title: LocalizedStringKey
	let content: Content

	@Namespace
	var namespace

	init(_ title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
		self.title = title
		self.content = content()
	}

	var body: some View {
#if os(watchOS)
		VStack(alignment: .leading) {
			Text(title)
				.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			content
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
#else
		HStack(alignment: .firstTextBaseline) {
			Text(title)
				.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer()

			content
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.accessibilityElement(children: .combine)
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
