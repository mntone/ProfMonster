import SwiftUI
import UniformTypeIdentifiers

#if os(iOS)

import class UIKit.UIPasteboard

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct CopyButton: View {
	let value: String

	@Environment(\.defaultMinListRowHeight)
	private var defaultMinListRowHeight

	var body: some View {
		Button("Copy", systemImage: "doc.on.doc") {
			UIPasteboard.general.setValue(value, forPasteboardType: UTType.plainText.identifier)
		}
		.buttonStyle(.borderless)
		.labelStyle(.iconOnly)
		.frame(height: defaultMinListRowHeight)
	}
}

#endif

#if !os(macOS)

@available(macOS, unavailable)
private struct _MAVerticalLabeledString<Label>: View where Label: View {
	let label: Label
	let value: String

#if os(iOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	@Namespace
	private var namespace

	var body: some View {
#if os(watchOS)
		VStack(alignment: .leading) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Text(value)
				.foregroundStyle(.secondary)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
#else
		HStack(spacing: 0.0) {
			VStack(alignment: .leading) {
				label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

				Text(value)
					.foregroundStyle(.secondary)
					.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
			}
			.preferredVerticalPadding()

			Spacer(minLength: 0.5 * horizontalLayoutMargin)

			CopyButton(value: value)
		}
		.multilineTextAlignment(.leading)
		.accessibilityElement(children: .combine)
#endif
	}
}

#endif

#if !os(watchOS)

@available(watchOS, unavailable)
private struct _MAHorizontalLabeledString<Label>: View where Label: View {
	let label: Label
	let value: String

#if os(iOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		HStack(alignment: .firstTextBaseline, spacing: 0.0) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer(minLength: 8.0)

			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				.textSelection(.enabled)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.padding(.vertical, 10.0)
		.accessibilityElement(children: .combine)
#else
		HStack(spacing: 0.5 * horizontalLayoutMargin) {
			label
				.accessibilityLabeledPair(role: .label, id: 0, in: namespace)
				.preferredVerticalPadding()

			Spacer(minLength: 0.0)

			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.leading)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
				.preferredVerticalPadding()

			CopyButton(value: value)
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
	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize
#endif

	init(_ value: String, @ViewBuilder label: () -> Label) {
		self.value = value
		self.label = label()
	}

	var body: some View {
#if os(iOS)
		if isAccessibilitySize {
			_MAVerticalLabeledString(label: label, value: value)
		} else {
			_MAHorizontalLabeledString(label: label, value: value)
		}
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
