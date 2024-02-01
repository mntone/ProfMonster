import SwiftUI

private struct _NarrowNavigationBarKey: EnvironmentKey {
	static var defaultValue: Bool {
		false
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension EnvironmentValues {
	var narrowNavigationBar: Bool {
		get { self[_NarrowNavigationBarKey.self] }
		set { self[_NarrowNavigationBarKey.self] = newValue }
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct NavigationBarTitleViewSupport<Content: View>: View {
	let content: Content

	@Environment(\.mobileMetrics)
	private var mobileMetrics

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		let narrow = narrowNavigationBar
		Group {
			if #available(iOS 16.0, *) {
				content
			} else {
				// Fix title are cut off on iOS 15.
				content.fixedSize()
			}
		}

		// Fix iOS 15
		.dynamicTypeSize(DynamicTypeSize.large...DynamicTypeSize.xxLarge)

		// Add narrow height support
		.environment(\.narrowNavigationBar, narrow)
	}

	private var narrowNavigationBar: Bool {
		if mobileMetrics.narrowNavigationBar,
		   verticalSizeClass == .compact {
			true
		} else {
			false
		}
	}
}
