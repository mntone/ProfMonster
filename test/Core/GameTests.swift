import Combine
import Swinject
import XCTest
@testable import MonsterAnalyzerCore

class GameTests: XCTestCase {
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
		erredDataSource.errorLevel = .game

		app.fetchIfNeeded()

		await app.getState(in: &cancellable)
		XCTAssertEqual(app.games.count, MockDataSource.config.titles.count)

		let game = app.games[0]
		game.fetchIfNeeded()

		let gameState = await game.getState(in: &cancellable)
		XCTAssertTrue(gameState.hasError)
		XCTAssertEqual(gameState.error, transformed)
		XCTAssertTrue(game.monsters.isEmpty)
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
