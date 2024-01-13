#if os(iOS)

import SwiftUI

@available(iOS, deprecated: 16.0)
@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct _NavigationBarTitleViewBackport<Content: View>: View {
	let content: Content

	@Environment(\.verticalSizeClass)
	private var verticalSizeClass

	var body: some View {
		content
			.fixedSize() // Fix title are cut off on iOS 15.
			.dynamicTypeSize(...maxDynamicTypeSize) // Fix iOS 15
	}

	private var maxDynamicTypeSize: DynamicTypeSize {
		if UIDevice.current.userInterfaceIdiom == .pad {
			DynamicTypeSize.xxLarge
		} else if UIDevice.current.model == "iPhone8,4" /* iPhone SE (1st generation) */,
				  verticalSizeClass == .compact {
			DynamicTypeSize.large
		} else {
			DynamicTypeSize.xxLarge
		}
	}
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct NavigationBarTitleViewSupport<Content: View>: View {
	let content: Content

	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}

	var body: some View {
		if #available(iOS 16.0, *) {
			content
		} else {
			_NavigationBarTitleViewBackport(content: content)
		}
	}
}

#endif
