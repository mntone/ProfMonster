import SwiftUI

struct SettingsButton: View {
#if os(iOS)
	let content: Button<ModifiedContent<Text, _PreferredVerticalPaddingModifier>>

	init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
		self.content = Button(action: action) {
			Text(titleKey)
				.preferredVerticalPadding()
		}
	}

	init<S>(verbatim title: S, action: @escaping () -> Void) where S: StringProtocol {
		self.content = Button(action: action) {
			Text(title)
				.preferredVerticalPadding()
		}
	}
#else
	let content: Button<Text>

	init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
		self.content = Button(titleKey, action: action)
	}

	init<S>(verbatim title: S, action: @escaping () -> Void) where S: StringProtocol {
		self.content = Button(title, action: action)
	}
#endif

	var body: some View {
		content
	}
}
