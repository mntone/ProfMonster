import SwiftUI

struct HorizontalLayoutMarginKey: EnvironmentKey {
	public static var defaultValue: CGFloat {
#if os(macOS)
		20.0
#else
		16.0
#endif
	}
}

extension EnvironmentValues {
	var horizontalLayoutMargin: CGFloat {
		get { self[HorizontalLayoutMarginKey.self] }
		set { self[HorizontalLayoutMarginKey.self] = newValue }
	}
}

@available(watchOS, unavailable)
struct _HorizontalLayoutMarginModifier: ViewModifier {
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	func body(content: Content) -> some View {
		content.padding(.horizontal, horizontalLayoutMargin)
	}
}

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
					Color.clear.onChange(of: proxy.size.width >= 400) { newValue in
						horizontalLayoutMargin = newValue ? 20 : 16
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
