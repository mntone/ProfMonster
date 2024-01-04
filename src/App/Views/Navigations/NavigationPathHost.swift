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
				await loadPath()
			}
			.onDisappear {
				storePath()
			}
			.onReceive(NotificationCenter.default.publisher(for: .platformWillResignActiveNotification), perform: storePath(_:))
	}

	private func loadPath() async {
		let path = await RouteHelper.load(from: pathString)
		var transaction = Transaction()
		transaction.disablesAnimations = true
		withTransaction(transaction) {
			self.path = path
		}
	}

	private func storePath(_: Notification) {
		storePath()
	}

	private func storePath() {
		pathString = RouteHelper.encode(path: path)
	}
}

#endif
