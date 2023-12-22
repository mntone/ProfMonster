import SwiftUI

public protocol PresentSettingsSheetAction {
	func callAsFunction()
}

private struct PresentSettingsSheetActionModifier: ViewModifier {
	let actions: PresentSettingsSheetAction

	func body(content: Content) -> some View {
		content
			.environment(\.presentSettingsSheetAction, actions)
	}
}

private struct PresentSettingsSheetActionImpl: PresentSettingsSheetAction {
	@Binding
	var isPresented: Bool

	func callAsFunction() {
		isPresented = true
	}
}

public extension View {
	func setPresentSettingsSheetAction(isPresented: Binding<Bool>) -> some View {
		modifier(PresentSettingsSheetActionModifier(actions: PresentSettingsSheetActionImpl(isPresented: isPresented)))
	}
}

private struct DefaultSettingsActionsImpl: PresentSettingsSheetAction {
	func callAsFunction() {}
}

public struct PresentSettingsSheetActionKey: EnvironmentKey {
	public static var defaultValue: PresentSettingsSheetAction {
		DefaultSettingsActionsImpl()
	}
}

public extension EnvironmentValues {
	var presentSettingsSheetAction: PresentSettingsSheetAction {
		get { self[PresentSettingsSheetActionKey.self] }
		set { self[PresentSettingsSheetActionKey.self] = newValue }
	}
}
