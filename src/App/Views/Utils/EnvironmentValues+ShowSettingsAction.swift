import SwiftUI

public protocol ShowSettingsAction {
	func callAsFunction()
}

#if os(macOS)

private struct _MacShowSettingsAction: ShowSettingsAction {
	func callAsFunction() {
		if #available(macOS 13.0, *) {
			NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
		} else {
			NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
		}
	}
}

#else

private struct _ShowSettingsActionImpl: ShowSettingsAction {
	@Binding
	private(set) var isPresented: Bool

	func callAsFunction() {
		isPresented = true
	}
}

@available(macOS, unavailable)
public extension View {
	func setShowSettings(isPresented: Binding<Bool>) -> some View {
		environment(\.showSettings, _ShowSettingsActionImpl(isPresented: isPresented))
	}
}

private struct _ShowSettingsNoAction: ShowSettingsAction {
	func callAsFunction() {}
}

#endif

private struct _ShowSettingsActionKey: EnvironmentKey {
	static var defaultValue: ShowSettingsAction {
#if os(macOS)
		_MacShowSettingsAction()
#else
		_ShowSettingsNoAction()
#endif
	}
}

public extension EnvironmentValues {
	var showSettings: ShowSettingsAction {
		get { self[_ShowSettingsActionKey.self] }
		set { self[_ShowSettingsActionKey.self] = newValue }
	}
}
