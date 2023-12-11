import SwiftUI

struct ContentView: View {
	private let viewModel: HomeViewModel

#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
#endif

	@Environment(\.scenePhase)
	private var scenePhase

	@SceneStorage("path")
	private var pathData: Data?

	@State
	private var path: [MARoute] = []

	@State
	private var isSettingsPresented: Bool = false

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		Group {
#if os(macOS)
			NavigationSplitViewHost(viewModel, path: $path)
#elseif os(watchOS)
			if #available(watchOS 9.0, *) {
				NavigationStackHost(viewModel, path: $path)
			} else {
				NavigationStackHostBackport(viewModel)
			}
#else
			if UIDevice.current.userInterfaceIdiom == .pad {
				NavigationSplitViewHost(viewModel, path: $path)
			} else if #available(iOS 16.0, *) {
				NavigationStackHost(viewModel, path: $path)
			} else {
				NavigationStackHostBackport(viewModel)
			}
#endif
		}
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainerView()
		}
		.setSettingsAction(isPresented: $isSettingsPresented)
		.task {
			if !MAApp.crashed {
				self.path = RouteHelper.decode(pathData: pathData)
			}
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
