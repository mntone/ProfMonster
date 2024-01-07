import SwiftUI

struct SettingsPicker<Content, SelectionValue, Preview>: View where Content: View, SelectionValue: Hashable, Preview: View {
	private let titleKey: LocalizedStringKey
	private let disablePreviews: [SelectionValue]?
	private let label: (SelectionValue) -> Text
	private let content: Content
	private let preview: ((SelectionValue) -> Preview)?

	@Binding
	private var selection: SelectionValue

	init(_ titleKey: LocalizedStringKey,
		 selection: Binding<SelectionValue>,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder label: @escaping (SelectionValue) -> Text) where Preview == EmptyView {
		self.titleKey = titleKey
		self.disablePreviews = nil
		self._selection = selection
		self.content = content()
		self.label = label
		self.preview = nil
	}

	init(_ titleKey: LocalizedStringKey,
		 selection: Binding<SelectionValue>,
		 disablePreviews: [SelectionValue]? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder label: @escaping (SelectionValue) -> Text,
		 @ViewBuilder preview: @escaping (SelectionValue) -> Preview) {
		self.titleKey = titleKey
		self.disablePreviews = disablePreviews
		self._selection = selection
		self.content = content()
		self.label = label
		self.preview = preview
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
#if os(iOS)
					.settingsPadding()
#endif
				} label: {
					Never?.none
				}
				.pickerStyle(.inline)

				if let preview,
				   !(disablePreviews?.contains(selection) ?? false) {
					Section("Preview") {
						preview(selection)
							.settingsPadding()
					}
				}
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
