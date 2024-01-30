import SwiftUI
import SwiftUIIntrospect

private struct _NavigationBarBackgroundHiddenModifier: ViewModifier {
	func body(content: Content) -> some View {
		content
			.introspect(.viewController, on: .iOS(.v15), scope: .ancestor) { viewController in
				guard viewController.navigationItem.standardAppearance == nil else {
					return
				}

				let appearance = UINavigationBarAppearance()
				appearance.configureWithTransparentBackground()
				viewController.navigationItem.standardAppearance = appearance
				viewController.navigationItem.compactAppearance = appearance
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
