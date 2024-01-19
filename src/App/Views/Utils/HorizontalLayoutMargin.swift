import SwiftUI

private struct _HorizontalLayoutMarginKey: EnvironmentKey {
	static var defaultValue: CGFloat {
#if os(macOS)
		20.0
#else
		16.0
#endif
	}
}

extension EnvironmentValues {
	var horizontalLayoutMargin: CGFloat {
		get { self[_HorizontalLayoutMarginKey.self] }
		set { self[_HorizontalLayoutMarginKey.self] = newValue }
	}
}

#if !os(watchOS)

@available(watchOS, unavailable)
struct _HorizontalLayoutMarginModifier: ViewModifier {
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	func body(content: Content) -> some View {
		content.padding(.horizontal, horizontalLayoutMargin)
	}
}

#endif

#if os(iOS)

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct _HorizontalLayoutMarginInjectModifier: ViewModifier {
	@State
	private var horizontalLayoutMargin: CGFloat = 16.0

	func body(content: Content) -> some View {
		content
			.background {
				GeometryReader { proxy in
					Color.clear
						.onAppear {
							let layoutMargin: CGFloat = proxy.size.width >= 400 ? 20 : 16
							if horizontalLayoutMargin != layoutMargin {
								horizontalLayoutMargin = layoutMargin
							}
						}
						.onChange(of: proxy.size.width >= 400) { newValue in
							let layoutMargin: CGFloat = newValue ? 20 : 16
							if horizontalLayoutMargin != layoutMargin {
								horizontalLayoutMargin = layoutMargin
							}
						}
				}
			}
			.environment(\.horizontalLayoutMargin, horizontalLayoutMargin)
	}
}

#endif

extension View {
#if os(watchOS)
	@inline(__always)
	func layoutMargin() -> Self {
		self
	}
#else
	@inline(__always)
	@ViewBuilder
	func layoutMargin() -> ModifiedContent<Self, _HorizontalLayoutMarginModifier> {
		modifier(_HorizontalLayoutMarginModifier())
	}
#endif

#if os(iOS)
	@inline(__always)
	@ViewBuilder
	func injectHorizontalLayoutMargin() -> ModifiedContent<Self, _HorizontalLayoutMarginInjectModifier> {
		modifier(_HorizontalLayoutMarginInjectModifier())
	}
#else
	@inline(__always)
	func injectHorizontalLayoutMargin() -> Self {
		self
	}
#endif
}
