import SwiftUI

struct SettingsToggle: View {
#if os(iOS)
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize
#endif

	let content: Toggle<Text>

	init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
		self.content = Toggle(titleKey, isOn: isOn)
	}

	var body: some View {
#if os(iOS)
		if dynamicTypeSize >= .accessibility1 {
			content.padding(.vertical, 16)
		} else if dynamicTypeSize >= .xxLarge {
			content.padding(.vertical, 4)
		} else {
			content
		}
#else
		content
#endif
	}
}
