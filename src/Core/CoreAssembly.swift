import Foundation
import Swinject

public final class CoreAssembly: Assembly {
	private let source: URL

	public init(source: URL = URL(string: "https://raw.githubusercontent.com/mntone/mhdata/main/")!) {
		self.source = source
	}

	public func assemble(container: Container) {
		container.register(LanguageService.self) { (_, keys: [String]) in
			MALanguageService(keys)
		}

#if DEBUG || targetEnvironment(simulator)
		if AppUtil.isPreview {
			assembleForPreview(container: container)
		} else {
			assembleForProduct(container: container)
		}
#else
		assembleForProduct(container: container)
#endif
	}

	private func assembleForProduct(container: Container) {
		let storage = DiskStorage()
		container.register(Storage.self) { _ in
			storage
		}

		let dataSource: MHDataSource = MHDataServer(source: MHClient(source: self.source), storage: storage)
		container.register(MHDataSource.self) { _ in
			dataSource
		}

		let app = App(container: container, dataSource: dataSource)
		container.register(App.self) { _ in
			app
		}
	}

#if DEBUG || targetEnvironment(simulator)
	private func assembleForPreview(container: Container) {
		let storage = MemoryStorage()
		container.register(Storage.self) { _ in
			storage
		}

		let dataSource: MHDataSource = MHMockDataOffer()
		container.register(MHDataSource.self) { _ in
			dataSource
		}

		let app = App(container: container, dataSource: dataSource)
		container.register(App.self) { _ in
			app
		}

		// Prefetch for Previews
		app.fetchIfNeeded()
		app.games.forEach { game in
			game.fetchIfNeeded()
		}
	}
#endif
}
