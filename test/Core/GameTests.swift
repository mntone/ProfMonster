import Swinject
import XCTest
@testable import MonsterAnalyzerCore

class GameTests: XCTestCase {
	var app: App!

	override func setUp() {
		let resolver = Assembler([
			CoreAssembly(mode: .develop),
			TestAssembly(),
		]).resolver
		app = App(resolver: resolver)
	}

	private func assertEqual(original: URLError.Code, transformed: StarSwingsError) throws {
		let erredDataSource = app.resolver.resolve(DataSource.self) as! ErredDataSource
		erredDataSource.error = URLError(original)
		erredDataSource.errorLevel = .game

		app.fetchIfNeeded()
		XCTAssertEqual(app.games.count, MockDataSource.config.titles.count)

		let game = app.games[0]
		game.fetchIfNeeded()

		XCTAssertTrue(game.state.hasError)
		XCTAssertEqual(game.state.error, transformed)
		XCTAssertTrue(game.monsters.isEmpty)
	}

	func testAppInit() {
		XCTAssertTrue(app.games.isEmpty)
		app.fetchIfNeeded()
		XCTAssertEqual(app.games.count, MockDataSource.config.titles.count)

		let game = app.games[0]
		game.fetchIfNeeded()
		XCTAssertEqual(game.monsters.count, MockDataSource.game.monsters.count)
	}

	func testNetworkErrorCanceled() throws {
		try assertEqual(original: .cancelled, transformed: .cancelled)
	}

	func testNetworkErrorConnectionLost() throws {
		try assertEqual(original: .networkConnectionLost, transformed: .connectionLost)
	}

	func testNetworkErrorCannotConnectToHost() throws {
		try assertEqual(original: .cannotConnectToHost, transformed: .noConnection)
	}

	func testNetworkErrorNoConnection() throws {
		try assertEqual(original: .notConnectedToInternet, transformed: .noConnection)
	}

	func testNetworkErrorTimedOut() throws {
		try assertEqual(original: .timedOut, transformed: .timedOut)
	}

	func testNetworkErrorNotExist() throws {
		try assertEqual(original: .fileDoesNotExist, transformed: .notExist)
	}

	func testNetworkErrorDataNotAllowed() throws {
		try assertEqual(original: .dataNotAllowed, transformed: .noConnection)
	}
}
