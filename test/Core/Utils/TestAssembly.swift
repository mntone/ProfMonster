import Swinject
import MonsterAnalyzerCore

struct TestAssembly: Assembly {
	func assemble(container: Container) {
		let wrappedDataSource = ErredDataSource(dataSource: container.resolve(DataSource.self)!)
		container.register(DataSource.self) { r in
			wrappedDataSource
		}

		let app = App(resolver: container)
		container.register(App.self) { _ in
			app
		}
	}
}
