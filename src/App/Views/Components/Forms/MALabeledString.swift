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
	
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Namespace
	private var namespace

	var body: some View {
#if os(macOS)
		HStack(alignment: .firstTextBaseline) {
			label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

			Spacer()

			Text(value)
				.foregroundStyle(.secondary)
				.multilineTextAlignment(.trailing)
				.textSelection(.enabled)
				.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
		}
		.accessibilityElement(children: .combine)
#else
		Menu {
			Button("Copy", systemImage: "doc.on.doc") {
				UIPasteboard.general.setValue(value, forPasteboardType: UTType.plainText.identifier)
			}
		} label: {
			HStack {
				label.accessibilityLabeledPair(role: .label, id: 0, in: namespace)

				Spacer()

				Text(value)
					.foregroundStyle(.secondary)
					.multilineTextAlignment(.trailing)
					.accessibilityLabeledPair(role: .content, id: 0, in: namespace)
			}
			.foregroundStyle(.foreground)
			.accessibilityElement(children: .combine)
			.padding(EdgeInsets(vertical: MAFormMetrics.verticalRowInset, horizontal: horizontalLayoutMargin))
		}
		.padding(EdgeInsets(vertical: -MAFormMetrics.verticalRowInset, horizontal: -horizontalLayoutMargin))
#endif
	}
}

#endif

struct MALabeledString<Label>: View where Label: View {
	let value: String
	let label: Label

#if os(iOS)
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize
#endif

	init(_ value: String, @ViewBuilder label: () -> Label) {
		self.value = value
		self.label = label()
	}

	var body: some View {
#if os(iOS)
		if dynamicTypeSize.isAccessibilitySize {
			_MAVerticalLabeledString(label: label, value: value)
				.padding(.vertical, 16)
		} else {
			_MAHorizontalLabeledString(label: label, value: value)
				.padding(.vertical, dynamicTypeSize >= .xxLarge ? 8.0 : 4.0)
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
