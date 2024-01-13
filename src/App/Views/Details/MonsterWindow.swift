import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterWindow: View {
	let id: CoordinatorUtil.MonsterIDType

#if os(iOS)
	@Environment(\.dismiss)
	private var dismiss
#endif

	var body: some View {
#if os(iOS)
		NavigationStack {
			MonsterPage(id: id)
				// For Stage Manager
				.frame(minWidth: 240.0, minHeight: 50.0)
				.toolbar {
					ToolbarItem(placement: .topBarLeading) {
						Button(role: .destructive, action: dismiss.callAsFunction) {
							Label("Close This Window", systemImage: "xmark")
						}
						.tint(.red)
					}
				}
		}
#endif
#if os(macOS)
		MonsterPage(id: id)
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
