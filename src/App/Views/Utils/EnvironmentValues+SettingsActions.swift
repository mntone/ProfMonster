import SwiftUI

public protocol SettingsAction {
	func present()
	func dismiss()
}

private struct SettingsActionModifier: ViewModifier {
	let actions: SettingsAction

	func body(content: Content) -> some View {
		content
			.environment(\.settingsAction, actions)
	}
}

private struct SettingsActionImpl: SettingsAction {
	@Binding
	var isPresented: Bool

	func present() {
		isPresented = true
	}

	func dismiss() {
		isPresented = false
	}
}

public extension View {
	func setSettingsAction(isPresented: Binding<Bool>) -> some View {
		modifier(SettingsActionModifier(actions: SettingsActionImpl(isPresented: isPresented)))
	}
}

private struct DefaultSettingsActionsImpl: SettingsAction {
	func present() {}
	func dismiss() {}
}

public struct SettingsActionKey: EnvironmentKey {
	public static var defaultValue: SettingsAction? {
		nil
	}
}

public extension EnvironmentValues {
	var settingsAction: SettingsAction? {
		get { self[SettingsActionKey.self] }
		set { self[SettingsActionKey.self] = newValue }
	}
}
