import MonsterAnalyzerCore
import Swinject

#if os(iOS)
import UIKit
#endif

struct AppAssembly: Assembly {
	func assemble(container: Container) {
#if os(iOS)
		let pad = UIDevice.current.userInterfaceIdiom == .pad
		let app = App(resolver: container.synchronize(), pad: pad)
#else
		let app = App(resolver: container.synchronize(), pad: false)
#endif
		container.register(App.self) { _ in
			app
		}

#if DEBUG || targetEnvironment(simulator)
		if AppUtil.isPreview {
			// Prefetch for Previews
			app.fetchIfNeeded()
			app.state.data?.forEach { game in
				game.fetchIfNeeded()
			}
		}
#endif
	}
}
