import SwiftUI

struct SettingsToggle: View {
#if os(iOS)
	let content: Toggle<ModifiedContent<Text, _PreferredVerticalPaddingModifier>>

	init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
		self.content = Toggle(isOn: isOn) {
			Text(titleKey)
				.preferredVerticalPadding()
		}
	}

	init<S>(verbatim title: S, isOn: Binding<Bool>) where S: StringProtocol {
		self.content = Toggle(isOn: isOn) {
			Text(title)
				.preferredVerticalPadding()
		}
	}
#else
	let content: Toggle<Text>

	init(_ titleKey: LocalizedStringKey, isOn: Binding<Bool>) {
		self.content = Toggle(titleKey, isOn: isOn)
	}

	init<S>(verbatim title: S, isOn: Binding<Bool>) where S: StringProtocol {
		self.content = Toggle(title, isOn: isOn)
	}
#endif

	var body: some View {
		content
	}
}
