import MonsterAnalyzerCore
import Swinject

struct AppAssembly: Assembly {
	func assemble(container: Container) {
		let app = App(resolver: container)
		container.register(App.self) { _ in
			app
		}

#if DEBUG || targetEnvironment(simulator)
		if AppUtil.isPreview {
			// Prefetch for Previews
			app.fetchIfNeeded()
			app.games.forEach { game in
				game.fetchIfNeeded()
			}
		}
#endif
	}
}
