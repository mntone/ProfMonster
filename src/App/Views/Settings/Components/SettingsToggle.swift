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
		content.padding(.vertical, verticalPadding)
#else
		content
#endif
	}

#if os(iOS)
	private var verticalPadding: CGFloat {
		switch dynamicTypeSize {
		case .accessibility1...:
			return 16.0
		case .xxLarge, .xxxLarge:
			return 4.0
		default:
			return 0.0
		}
	}
#endif
}
