import SwiftUI

private struct _CloseButtonDisabled {
	@Binding
	var isDisabled: Bool
}

private struct _CloseButtonDisabledKey: EnvironmentKey {
	static var defaultValue: _CloseButtonDisabled {
		_CloseButtonDisabled(isDisabled: .constant(false))
	}
}

private extension EnvironmentValues {
	var _isCloseButtonDisabled: _CloseButtonDisabled {
		get { self[_CloseButtonDisabledKey.self] }
		set { self[_CloseButtonDisabledKey.self] = newValue }
	}
}

@available(watchOS, unavailable)
struct CloseButtonDisabledModifiers: ViewModifier {
	let isDisabled: Bool

	@Environment(\._isCloseButtonDisabled)
	private var isCloseButtonDisabled

	@State
	private var previousState: Bool = false

	fileprivate init(isDisabled: Bool) {
		self.isDisabled = isDisabled
	}

	func body(content: Content) -> some View {
		content
			.onAppear {
				previousState = isCloseButtonDisabled.isDisabled
				isCloseButtonDisabled.isDisabled = isDisabled
			}
			.onChange(of: isDisabled) { newValue in
				isCloseButtonDisabled.isDisabled = newValue
			}
			.onDisappear {
				isCloseButtonDisabled.isDisabled = previousState
			}
	}
}

@available(watchOS, unavailable)
extension View {
	func closeButtonDisabled() -> ModifiedContent<Self, CloseButtonDisabledModifiers> {
		modifier(CloseButtonDisabledModifiers(isDisabled: true))
	}

	func closeButtonDisabled(_ isDisabled: Bool) -> ModifiedContent<Self, CloseButtonDisabledModifiers> {
		modifier(CloseButtonDisabledModifiers(isDisabled: isDisabled))
	}

	func setCloseButtonDisabled(_ isDisabled: Binding<Bool>) -> some View {
		environment(\._isCloseButtonDisabled, _CloseButtonDisabled(isDisabled: isDisabled))
	}
}
