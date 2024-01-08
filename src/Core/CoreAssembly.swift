import Foundation
import Swinject

#if DEBUG || targetEnvironment(simulator)
public enum CoreAssemblyMode {
	case auto
	case develop
	case product
}
#endif

public struct CoreAssembly: Assembly {
#if DEBUG || targetEnvironment(simulator)
	private let mode: CoreAssemblyMode
#endif
	private let source: URL

#if DEBUG || targetEnvironment(simulator)
	public init(mode: CoreAssemblyMode = .auto,
				source: URL = URL(string: "https://raw.githubusercontent.com/mntone/mhdata/main/")!) {
		self.mode = mode
		self.source = source
	}
#else
	public init(source: URL = URL(string: "https://raw.githubusercontent.com/mntone/mhdata/main/")!) {
		self.source = source
	}
#endif

	public func assemble(container: Container) {
		let logger = AppleLogger()
		container.register(Logger.self) { _ in
			logger
		}

		container.register(LanguageService.self) { (_, keys: [String]) in
			MALanguageService(keys)
		}

#if targetEnvironment(simulator)
		let options = CoreDataUserDatabaseOptions(useCloud: false)
#else
		let options = CoreDataUserDatabaseOptions.default
#endif
		let userDatabase = CoreDataUserDatabase(logger: logger, options: options)
		container.register(UserDatabase.self) { (_) in
			userDatabase
		}

#if DEBUG || targetEnvironment(simulator)
		switch mode {
		case .auto:
			if AppUtil.isPreview {
				assembleForDevelop(container: container)
			} else {
				assembleForProduct(container: container, logger: logger)
			}
		case .develop:
			assembleForDevelop(container: container)
		case .product:
			assembleForProduct(container: container, logger: logger)
		}
#else
		assembleForProduct(container: container, logger: logger)
#endif
	}

	private func assembleForProduct(container: Container, logger: Logger) {
		let storage = DiskStorage(logger: logger)
		container.register(Storage.self) { _ in
			storage
		}

		let dataSource: DataSource = CacheableDataSource(source: NetworkDataSource(source: self.source, logger: logger), storage: storage)
		container.register(DataSource.self) { _ in
			dataSource
		}
	}

#if DEBUG || targetEnvironment(simulator)
	private func assembleForDevelop(container: Container) {
		let storage = MemoryStorage()
		container.register(Storage.self) { _ in
			storage
		}

		let dataSource: DataSource = MockDataSource()
		container.register(DataSource.self) { _ in
			dataSource
		}
	}
#endif
}
