import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

struct NavigationPathHost<Content: View>: View {
	@Environment(\.scenePhase)
	private var scenePhase

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
			.onChange(of: scenePhase) { newValue in
				switch newValue {
				case .background, .active:
					break
				case .inactive:
					if scenePhase == .active {
						storePath()
					}
					break
				@unknown default:
					fatalError()
				}
			}
	}

	private func storePath() {
		pathString = RouteHelper.encode(path: path)
	}
}

#endif
