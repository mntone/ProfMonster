import SwiftUI

struct PreferredPicker<Data: RandomAccessCollection, Content: View>: View where Data.Element: Hashable, Data.Element: Identifiable {
	private let titleKey: LocalizedStringKey
	private let data: Data
	private let content: (Data.Element) -> Content

	@Binding
	private var selection: Data.Element

	init(_ titleKey: LocalizedStringKey,
		 data: Data,
		 selection: Binding<Data.Element>,
		 @ViewBuilder content: @escaping (Data.Element) -> Content) {
		self.titleKey = titleKey
		self.data = data
		self._selection = selection
		self.content = content
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
				Picker(selection: $selection) {
					ForEach(data) { item in
						content(item).tag(item)
					}
				} label: {
					EmptyView()
				}
				.pickerStyle(.inline)
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
