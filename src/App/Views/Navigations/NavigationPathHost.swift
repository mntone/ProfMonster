import SwiftUI

#if !os(macOS)

struct NavigationPathHost<Content: View>: View {
	@Environment(\.scenePhase)
	private var scenePhase

	@SceneStorage("path")
	private var pathData: Data?

	@ViewBuilder
	let content: (_ path: Binding<[MARoute]>) -> Content

	@State
	private var path: [MARoute] = []

	var body: some View {
		content($path)
			.onAppear {
				let notCrashed = !MAApp.crashed
				MAApp.resetCrashed()
				guard notCrashed else {
					return
				}

				path = RouteHelper.decode(pathData: pathData)
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
		pathData = RouteHelper.encode(path: path)
	}
}

#endif
