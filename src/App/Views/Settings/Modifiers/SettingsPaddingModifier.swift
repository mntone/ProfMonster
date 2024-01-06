import SwiftUI

struct _SettingsPaddingModifier: ViewModifier {
#if os(iOS)
	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	func body(content: Content) -> some View {
		if dynamicTypeSize >= .accessibility1 {
			content.padding(.vertical, 16)
		} else if dynamicTypeSize >= .xxLarge {
			content.padding(.vertical, 8)
		} else {
			content
		}
	}
#else
	func body(content: Content) -> some View {
		content
	}
#endif
}

extension View {
	@ViewBuilder
	func settingsPadding() -> ModifiedContent<Self, _SettingsPaddingModifier> {
		modifier(_SettingsPaddingModifier())
	}
}
