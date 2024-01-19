import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)
import class UIKit.UIPasteboard
#endif

#if !os(macOS)

@available(macOS, unavailable)
struct _MAVerticalLabeledString<Label>: View where Label: View {
	let label: Label
	let value: String

	@Namespace
	private var namespace

	var body: some View {
		VStack(alignment: .leading) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Text(value)
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
	}
}

#endif

#if !os(watchOS)

@available(watchOS, unavailable)
struct _MAHorizontalLabeledString<Label>: View where Label: View {
	let label: Label
	let value: String

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		HStack(alignment: .firstTextBaseline) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer()

			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				.textSelection(.enabled)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.padding(.vertical, 10.0)
		.accessibilityElement(children: .combine)
#else
		HStack(spacing: 0.0) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer()

			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.accessibilityElement(children: .combine)
#endif
	}
}

#endif

struct MALabeledString<Label>: View where Label: View {
	let value: String
	let label: Label

#if os(iOS)
	@Environment(\.defaultMinListRowHeight)
	private var defaultMinListRowHeight

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	init(_ value: String, @ViewBuilder label: () -> Label) {
		self.value = value
		self.label = label()
	}

	var body: some View {
#if os(iOS)
		HStack(spacing: 0.0) {
			if dynamicTypeSize.isAccessibilitySize {
				_MAVerticalLabeledString(label: label, value: value)
					.padding(.vertical, 20.0)

				Spacer(minLength: 0.0)
			} else {
				_MAHorizontalLabeledString(label: label, value: value)
					.padding(.vertical, dynamicTypeSize >= .xxLarge ? 15.0 : 10.0)
			}

			Button {
				UIPasteboard.general.setValue(value, forPasteboardType: UTType.plainText.identifier)
			} label: {
				SwiftUI.Label("Copy", systemImage: "doc.on.doc")
					.labelStyle(.iconOnly)
			}
			.buttonStyle(.borderless)
			.frame(width: 48.0, height: defaultMinListRowHeight)
		}
		.padding(.trailing, dynamicTypeSize.isAccessibilitySize ? 0.0 : -horizontalLayoutMargin)
		.frame(maxWidth: .infinity)
		.accessibilityElement(children: .combine)
#elseif os(watchOS)
		_MAVerticalLabeledString(label: label, value: value)
#else
		_MAHorizontalLabeledString(label: label, value: value)
#endif
	}
}

extension MALabeledString where Label == Text {
	init<S>(_ title: S, value: String) where S: StringProtocol {
		self.label = Text(title)
		self.value = value
	}

	init(_ titleKey: LocalizedStringKey, value: String) {
		self.label = Text(titleKey)
		self.value = value
	}
}
