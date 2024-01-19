import SwiftUI

@available(watchOS, unavailable)
private struct _MAListRowSpacingKey: EnvironmentKey {
	static var defaultValue: CGFloat? {
		nil
	}
}

@available(watchOS, unavailable)
private struct _MAListSectionSpacingKey: EnvironmentKey {
	static var defaultValue: CGFloat {
#if os(macOS)
		10.0
#else
		18.0
#endif
	}
}

@available(watchOS, unavailable)
private struct _MAListIgnoreLayoutMarginKey: EnvironmentKey {
	static var defaultValue: Bool {
		false
	}
}

@available(watchOS, unavailable)
extension EnvironmentValues {
	var defaultListRowSpacing: CGFloat? {
		get { self[_MAListRowSpacingKey.self] }
		set { self[_MAListRowSpacingKey.self] = newValue }
	}

	var defaultListSectionSpacing: CGFloat {
		get { self[_MAListSectionSpacingKey.self] }
		set { self[_MAListSectionSpacingKey.self] = newValue }
	}

	var _ignoreLayoutMargin: Bool {
		get { self[_MAListIgnoreLayoutMarginKey.self] }
		set { self[_MAListIgnoreLayoutMarginKey.self] = newValue }
	}
}

@available(watchOS, unavailable)
extension View {
	@inline(__always)
	func ignoreLayoutMargin() -> some View {
		environment(\._ignoreLayoutMargin, true)
	}
}
