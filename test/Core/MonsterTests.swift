import Combine
import Swinject
import XCTest
@testable import MonsterAnalyzerCore

class MonsterTests: XCTestCase {
	private var cancellable = Set<AnyCancellable>()
	private var app: App!

	override func setUp() {
		let resolver = Assembler([
			CoreAssembly(mode: .develop),
			TestAssembly(),
		]).resolver
		app = App(resolver: resolver)
	}

	private func assertEqual(original: URLError.Code, transformed: StarSwingsError) async throws {
		let erredDataSource = app.resolver.resolve(DataSource.self) as! ErredDataSource
		erredDataSource.error = URLError(original)
		erredDataSource.errorLevel = .monster

		app.fetchIfNeeded()

		await app.getState(in: &cancellable)
		XCTAssertEqual(app.games.count, 1)

		let game = app.games[0]
		game.fetchIfNeeded()

		await game.getState(in: &cancellable)
		XCTAssertEqual(game.monsters.count, MockDataSource.config.titles.count)

		let monster = game.monsters[0]
		monster.fetchIfNeeded()

		let monsterState = await monster.getState(in: &cancellable)
		XCTAssertTrue(monsterState.hasError)
		XCTAssertEqual(monsterState.error, transformed)
		XCTAssertNil(monster.physiologies)
	}

	func testAppInit() async {
		XCTAssertTrue(app.games.isEmpty)
		app.fetchIfNeeded()

		await app.getState(in: &cancellable)
		XCTAssertEqual(app.games.count, MockDataSource.config.titles.count)

		let game = app.games[0]
		game.fetchIfNeeded()

		await game.getState(in: &cancellable)
		XCTAssertEqual(game.monsters.count, MockDataSource.game.monsters.count)

		let monster = game.monsters[0]
		monster.fetchIfNeeded()

		await monster.getState(in: &cancellable)
		XCTAssertNotNil(monster.physiologies)
	}

	func testNetworkErrorCanceled() async throws {
		try await assertEqual(original: .cancelled, transformed: .cancelled)
	}

	func testNetworkErrorConnectionLost() async throws {
		try await assertEqual(original: .networkConnectionLost, transformed: .connectionLost)
	}

	func testNetworkErrorCannotConnectToHost() async throws {
		try await assertEqual(original: .cannotConnectToHost, transformed: .noConnection)
	}

	func testNetworkErrorNoConnection() async throws {
		try await assertEqual(original: .notConnectedToInternet, transformed: .noConnection)
	}

	func testNetworkErrorTimedOut() async throws {
		try await assertEqual(original: .timedOut, transformed: .timedOut)
	}

	func testNetworkErrorNotExist() async throws {
		try await assertEqual(original: .fileDoesNotExist, transformed: .notExist)
	}

	func testNetworkErrorDataNotAllowed() async throws {
		try await assertEqual(original: .dataNotAllowed, transformed: .noConnection)
	}
}
