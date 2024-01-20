import SwiftUI

#if os(iOS) || os(macOS)

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
		24.0
#endif
	}
}

@available(watchOS, unavailable)
private struct _MAListInOwnerdrawBackgroundContextKey: EnvironmentKey {
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

	var _inOwnerdrawBackgroundContext: Bool {
		get { self[_MAListInOwnerdrawBackgroundContextKey.self] }
		set { self[_MAListInOwnerdrawBackgroundContextKey.self] = newValue }
	}
}

#endif

private struct _MAListIgnoreLayoutMarginKey: EnvironmentKey {
	static var defaultValue: Bool {
		false
	}
}

extension EnvironmentValues {
	var _ignoreLayoutMargin: Bool {
		get { self[_MAListIgnoreLayoutMarginKey.self] }
		set { self[_MAListIgnoreLayoutMarginKey.self] = newValue }
	}
}

extension View {
	@inline(__always)
	func ignoreLayoutMargin() -> some View {
		environment(\._ignoreLayoutMargin, true)
	}
}
