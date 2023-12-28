import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct NavigationPathHost<Content: View>: View {
	@Binding
	var pathString: String?

	@ViewBuilder
	let content: (_ path: Binding<[MARoute]>) -> Content

	@State
	private var path: [MARoute] = []

	var body: some View {
		content($path)
			.task {
				path = await RouteHelper.load(from: pathString)
			}
			.onDisappear {
				storePath()
			}
			.onReceive(NotificationCenter.default.publisher(for: .platformWillResignActiveNotification), perform: storePath(_:))
	}

	private func storePath(_: Notification) {
		storePath()
	}

	private func storePath() {
		pathString = RouteHelper.encode(path: path)
	}
}

#endif
