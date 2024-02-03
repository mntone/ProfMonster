import MonsterAnalyzerCore
import Swinject

#if os(iOS)
import UIKit
#endif

struct AppAssembly: Assembly {
	func assemble(container: Container) {
#if os(iOS)
		let pad = UIDevice.current.userInterfaceIdiom == .pad
#elseif os(macOS)
		let pad = true
#else
		let pad = false
#endif
		container
			.register(App.self) { _ in
				App(container: container,
					requestBehavior: .exponentialDelayed(initial: 3.0, multiplier: 2.0, max: 24.0),
					pad: pad)
			}
			.inObjectScope(.container)

#if DEBUG || targetEnvironment(simulator)
		if AppUtil.isPreview {
			// Prefetch for Previews
			let app = container.resolve(App.self)!
			app.fetchIfNeeded()
			app.state.data?.forEach { game in
				game.fetchIfNeeded()
			}
		}
#endif
	}
}
