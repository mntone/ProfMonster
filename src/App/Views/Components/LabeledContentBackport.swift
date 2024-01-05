import SwiftUI

struct LabeledContentBackport<Label, Content>: View where Label: View, Content: View {
	let label: Label
	let content: Content

	@Namespace
	var namespace

	init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
		self.label = label()
		self.content = content()
	}

	var body: some View {
#if os(watchOS)
		VStack(alignment: .leading) {
			label
				.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			content
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
#else
		HStack {
			label
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

extension LabeledContentBackport where Label == Text {
	init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
		self.label = Text(title)
		self.content = content()
	}

	init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
		self.label = Text(titleKey)
		self.content = content()
	}
}

extension LabeledContentBackport where Label == Text, Content == Text {
	init<S1, S2>(_ title: S1, value: S2) where S1: StringProtocol, S2: StringProtocol {
		self.label = Text(title)
		self.content = Text(value)
	}

	init<S>(_ titleKey: LocalizedStringKey, value: S) where S: StringProtocol {
		self.label = Text(titleKey)
		self.content = Text(value)
	}
}
