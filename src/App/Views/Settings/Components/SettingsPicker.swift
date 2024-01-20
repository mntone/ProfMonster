import SwiftUI

struct SettingsPicker<Content, SelectionValue, MoreContent>: View where Content: View, SelectionValue: Hashable, MoreContent: View {
	private let titleKey: LocalizedStringKey
	private let label: (SelectionValue) -> Text
	private let content: Content
	private let moreContent: MoreContent?

	@Binding
	private var selection: SelectionValue

	init(_ titleKey: LocalizedStringKey,
		 selection: Binding<SelectionValue>,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder label: @escaping (SelectionValue) -> Text) where MoreContent == EmptyView {
		self.titleKey = titleKey
		self._selection = selection
		self.content = content()
		self.label = label
		self.moreContent = nil
	}

	init(_ titleKey: LocalizedStringKey,
		 selection: Binding<SelectionValue>,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder label: @escaping (SelectionValue) -> Text,
		 @ViewBuilder more: () -> MoreContent) {
		self.titleKey = titleKey
		self._selection = selection
		self.content = content()
		self.label = label
		self.moreContent = more()
	}

	var body: some View {
#if os(macOS)
		Picker(titleKey, selection: $selection) {
			content
		}
#else
		NavigationLink {
			SettingsPreferredList {
				// Apple Watch require THIS LEVEL.
				// Inlined Picker is styled correctly only directly below Form.
				Picker(selection: $selection) {
					content
//#if os(iOS)
					//.preferredVerticalPadding()
//#endif
				} label: {
					Never?.none
				}
				.pickerStyle(.inline)

				moreContent
			}
			.navigationTitle(titleKey)
		} label: {
			SettingsLabeledContent(titleKey) {
				label(selection)
					.foregroundStyle(.secondary)
			}
		}
#endif
	}
}
