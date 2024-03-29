import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterWindow: View {
	let id: CoordinatorUtil.MonsterIDType

#if os(iOS)
	@Environment(\.dismiss)
	private var dismiss

	@EnvironmentObject
	private var sceneDelegate: SceneDelegate
#endif

	var body: some View {
#if os(iOS)
		NavigationStack {
			MonsterPage(id: id, root: true)
				// For Stage Manager
				.frame(minWidth: 240.0, minHeight: 50.0)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button("Close This Window",
							   systemImage: "xmark",
							   role: .destructive,
							   action: dismiss.callAsFunction)
							.tint(.red)
							.accessibilityLabel("Close This Window")
					}
				}
		}
		.injectHorizontalLayoutMargin()
		.environment(\.mobileMetrics, DynamicMobileMetrics(sceneDelegate.window))
#endif
#if os(macOS)
		MonsterPage(id: id, root: true)
			.frame(minWidth: 480.0, minHeight: 50.0)
#endif
	}

#if os(iOS)
	static let defaultSize: CGSize = CGSize(width: 320.0, height: 500.0)
#endif
#if os(macOS)
	static let defaultSize: CGSize = CGSize(width: 480.0, height: 640.0)
#endif
}
