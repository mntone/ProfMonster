import SwiftUI

#if os(watchOS)

struct SettingsLabeledContent<Label, Content>: View where Label: View, Content: View {
	let content: Content
	let label: Label

	@Namespace
	var namespace

	init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
		self.label = label()
		self.content = content()
	}

	var body: some View {
		VStack(alignment: .leading) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			content.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
	}
}

#endif

#if os(macOS)

@available(iOS, unavailable)
@available(watchOS, unavailable)
private struct _HorizontalLabeledContent<Label, Content>: View where Label: View, Content: View {
	let content: Content
	let label: Label

	@Namespace
	private var namespace

	var body: some View {
		HStack {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer()

			content.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.accessibilityElement(children: .combine)
	}
}

struct SettingsLabeledContent<Label, Content>: View where Label: View, Content: View {
	let label: Label
	let content: Content

	init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
		self.label = label()
		self.content = content()
	}

	var body: some View {
		if #available(macOS 13.0, *) {
			LabeledContent {
				content
			} label: {
				label
			}
		} else {
			_HorizontalLabeledContent(content: content, label: label)
		}
	}
}

#endif

#if os(iOS)

struct SettingsLabeledContent<Label, Content>: View where Label: View, Content: View {
	let content: Content
	let label: Label

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@Namespace
	private var namespace

	@ScaledMetric(relativeTo: .body)
	private var verticalPadding: CGFloat = 11.0

	init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
		self.label = label()
		self.content = content()
	}

	var body: some View {
		Group {
			if dynamicTypeSize.isAccessibilitySize {
				VStack(alignment: .leading, spacing: 8.0) {
					label
						.accessibilityLabeledPair(role: .label, id: 1, in: namespace)

					content
						.accessibilityLabeledPair(role: .content, id: 1, in: namespace)
				}
				.multilineTextAlignment(.leading)
				.padding(EdgeInsets(top: verticalPadding,
									leading: 0.0,
									bottom: verticalPadding,
									trailing: 0.0))
			} else {
				HStack(spacing: 0) {
					label
						.padding(EdgeInsets(top: verticalPadding,
											leading: 0.0,
											bottom: verticalPadding,
											trailing: 0.0))
						.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

					Spacer(minLength: 8.0)

					if content is Text {
						content
							.preferredVerticalPadding()
							.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
					} else {
						content
							.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
					}
				}
			}
		}
		.accessibilityElement(children: .combine)
	}
}

#endif

extension SettingsLabeledContent where Label == Text {
	init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
		self.label = Text(title)
		self.content = content()
	}

	init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
		self.label = Text(titleKey)
		self.content = content()
	}
}

extension SettingsLabeledContent where Label == Text, Content == Text {
	init<S1, S2>(_ title: S1, value: S2) where S1: StringProtocol, S2: StringProtocol {
		self.label = Text(title)
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			self.content = Text(value).foregroundStyle(.secondary)
		} else {
			self.content = Text(value).foregroundColor(.secondary)
		}
	}

	init<S>(_ titleKey: LocalizedStringKey, value: S) where S: StringProtocol {
		self.label = Text(titleKey)
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			self.content = Text(value).foregroundStyle(.secondary)
		} else {
			self.content = Text(value).foregroundColor(.secondary)
		}
	}
}
