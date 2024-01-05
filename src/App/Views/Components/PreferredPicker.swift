import SwiftUI

struct PreferredPicker<Data: RandomAccessCollection, Content: View, Preview>: View where Data.Element: Hashable, Data.Element: Identifiable, Preview: View {
	private let titleKey: LocalizedStringKey
	private let data: Data
	private let disablePreviews: [Data.Element]?
	private let content: (Data.Element) -> Content
	private let preview: ((Data.Element) -> Preview)?

	@Binding
	private var selection: Data.Element

	init(_ titleKey: LocalizedStringKey,
		 data: Data,
		 selection: Binding<Data.Element>,
		 @ViewBuilder content: @escaping (Data.Element) -> Content) where Preview == EmptyView {
		self.titleKey = titleKey
		self.data = data
		self.disablePreviews = nil
		self._selection = selection
		self.content = content
		self.preview = nil
	}

	init(_ titleKey: LocalizedStringKey,
		 data: Data,
		 selection: Binding<Data.Element>,
		 disablePreviews: [Data.Element]? = nil,
		 @ViewBuilder content: @escaping (Data.Element) -> Content,
		 @ViewBuilder preview: @escaping (Data.Element) -> Preview) {
		self.titleKey = titleKey
		self.data = data
		self.disablePreviews = disablePreviews
		self._selection = selection
		self.content = content
		self.preview = preview
	}

	var body: some View {
#if os(macOS)
		Picker(titleKey, selection: $selection) {
			ForEach(data) { item in
				content(item).tag(item)
			}
		}
#else
		NavigationLink {
			Form {
				Section {
					Picker(selection: $selection) {
						ForEach(data) { item in
							content(item).tag(item)
						}
					} label: {
						Never?.none
					}
					.pickerStyle(.inline)
				}

				if let preview,
				   !(disablePreviews?.contains(selection) ?? false) {
					Section("Preview") {
						preview(selection)
					}
				}
			}
			.navigationTitle(titleKey)
		} label: {
			if #available(iOS 16.0, watchOS 9.0, *) {
				LabeledContent(titleKey) {
					content(selection)
				}
			} else {
				LabeledContentBackport(titleKey) {
					content(selection)
				}
			}
		}
#endif
	}
}
