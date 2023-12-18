import Swinject
import XCTest
@testable import MonsterAnalyzerCore

class MonsterTests: XCTestCase {
	var app: App!

	override func setUp() {
		let resolver = Assembler([
			CoreAssembly(mode: .develop),
			TestAssembly(),
		]).resolver
		app = App(resolver: resolver)
	}

	private func assertEqual(original: URLError.Code, transformed: StarSwingsError) throws {
		let erredDataSource = app.resolver.resolve(MHDataSource.self) as! ErredDataSource
		erredDataSource.error = URLError(original)
		erredDataSource.errorLevel = .monster

		app.fetchIfNeeded()
		XCTAssertEqual(app.games.count, 1)

		let game = app.games[0]
		game.fetchIfNeeded()

		XCTAssertEqual(game.monsters.count, MHMockDataOffer.config.titles.count)

		let monster = game.monsters[0]
		monster.fetchIfNeeded()

		XCTAssertTrue(monster.state.hasError)
		XCTAssertEqual(monster.state.error, transformed)
		XCTAssertNil(monster.physiologies)
	}

	func testAppInit() {
		XCTAssertTrue(app.games.isEmpty)
		app.fetchIfNeeded()
		XCTAssertEqual(app.games.count, MHMockDataOffer.config.titles.count)

		let game = app.games[0]
		game.fetchIfNeeded()
		XCTAssertEqual(game.monsters.count, MHMockDataOffer.game.monsters.count)

		let monster = game.monsters[0]
		monster.fetchIfNeeded()
		XCTAssertNotNil(monster.physiologies)
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
