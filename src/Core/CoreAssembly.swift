import Foundation
import Swinject

public final class CoreAssembly: Assembly {
	private let source: URL

	public init(source: URL = URL(string: "https://raw.githubusercontent.com/mntone/mhdata/main/")!) {
		self.source = source
	}

	public func assemble(container: Container) {
		container.register(TextProcessor.self) { _ in
			LanguageUtil.textProcessor
		}

		let storage = HybridStorage()
		container.register(Storage.self) { _ in
			storage
		}

#if targetEnvironment(simulator)
		if AppUtil.isPreview {
			container.register(MHDataSource.self) { _ in
				MHMockDataOffer()
			}
		} else {
			container.register(MHDataSource.self) { _ in
				MHDataServer(source: MHClient(source: self.source), storage: storage)
			}
		}
#else
		container.register(MHDataSource.self) { _ in
			MHDataServer(source: MHClient(source: self.source), storage: storage)
		}
#endif

		container.register(LanguageService.self) { resolver, id in
			guard let source = resolver.resolve(MHDataSource.self) else {
				fatalError()
			}
			return MALanguageService(source: source, id: id)
		}
	}
}
