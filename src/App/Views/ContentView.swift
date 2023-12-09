import SwiftUI

@available(iOS 16.1, macOS 13.1, watchOS 9.1, *)
struct ContentView: View {
	@ObservedObject
	private var viewModel: HomeViewModel

	@Environment(\.scenePhase)
	private var scenePhase

	@SceneStorage("path")
	private var pathData: Data?

	@State
	private var path = NavigationPath()

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		NavigationStack(path: $path) {
			HomeView(viewModel)
				.navigationDestination(for: MARoute.self) { path in
					switch path {
					case let .game(gameId):
						GameView(viewModel.getOrCreate(id: gameId))
					case let .monster(gameId, monsterId):
						MonsterView(viewModel.getOrCreate(id: gameId).getOrCreate(id: monsterId))
					}
				}
		}.onChange(of: scenePhase) { newValue in
			switch newValue {
			case .background, .active:
				break
			case .inactive:
				if scenePhase == .active {
					pathData = RouteHelper.encode(path: path)
				}
				break
			@unknown default:
				fatalError()
			}
		}.task {
			if !MAApp.crashed,
			   let path = RouteHelper.decode(pathData: pathData) {
				self.path = path
			}
		}
	}
}

struct ContentViewBackport: View {
	@ObservedObject
	private var viewModel: HomeViewModel

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		NavigationView {
			HomeView(viewModel)
		}
	}
}

@available(iOS 16.1, macOS 13.1, watchOS 9.1, *)
#Preview {
	ContentView(HomeViewModel())
}
