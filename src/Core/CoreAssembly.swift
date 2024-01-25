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

	public init(mode: CoreAssemblyMode = .auto) {
		self.mode = mode
	}
#endif

	public func assemble(container: Container) {
		let logger = AppleLogger()
		container.register(Logger.self) { _ in
			logger
		}

		container.register(LanguageServiceInternal.self) { (_, localeKey: String, localization: MHLocalization) in
			MALanguageService(localeKey: localeKey,
							  localization: localization)
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

		container.register(DataSource.self) { (_, source: URL) in
			CacheableDataSource(source: NetworkDataSource(source: source, logger: logger), storage: storage)
		}
	}

#if DEBUG || targetEnvironment(simulator)
	private func assembleForDevelop(container: Container) {
		let storage = MemoryStorage()
		container.register(Storage.self) { _ in
			storage
		}

		let dataSource: DataSource = MockDataSource()
		container.register(DataSource.self) { (_, _: URL) in
			dataSource
		}
	}
#endif
}
