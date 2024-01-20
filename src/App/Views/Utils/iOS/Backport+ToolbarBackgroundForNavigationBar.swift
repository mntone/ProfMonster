#if os(iOS)

import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

private struct _NavigationBarBackgroundHiddenModifier: ViewModifier {
	@Weak
	private var navigationController: UINavigationController?

	func body(content: Content) -> some View {
		content
			.introspect(.navigationView(style: .stack), on: .iOS(.v15), scope: .ancestor) { navigationController in
				let appearance = UINavigationBarAppearance()
				appearance.configureWithTransparentBackground()
				navigationController.navigationBar.standardAppearance = appearance
				navigationController.navigationBar.compactAppearance = appearance
				self.navigationController = navigationController
			}
			.onDisappear {
				if let navigationController {
					let appearance = UINavigationBarAppearance()
					appearance.configureWithDefaultBackground()
					navigationController.navigationBar.standardAppearance = appearance
					navigationController.navigationBar.compactAppearance = appearance
				}
			}
	}
}

@available(iOS 15.0, *)
@available(macOS, unavailable)
@available(watchOS, unavailable)
extension Backport where Content: View {
	@ViewBuilder
	public func toolbarBackgroundForNavigationBar(_ visibility: Visibility) -> some View {
		if #available(iOS 16.0, *) {
			content.toolbarBackground(visibility, for: .navigationBar)
		} else if visibility == .hidden {
			content.modifier(_NavigationBarBackgroundHiddenModifier())
		} else {
			content
		}
	}
}

#endif
