import Combine
import Swinject
import XCTest
@testable import MonsterAnalyzerCore

class AppTests: XCTestCase {
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
		erredDataSource.errorLevel = .config

		app.fetchIfNeeded()

		let state = await app.getState(in: &cancellable)
		XCTAssertTrue(state.hasError)
		XCTAssertEqual(state.error, transformed)
	}

	func testInit() {
		XCTAssertTrue(app.state.isReady)
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
		try await assertEqual(original: .fileDoesNotExist, transformed: .notExists)
	}

	func testNetworkErrorDataNotAllowed() async throws {
		try await assertEqual(original: .dataNotAllowed, transformed: .noConnection)
	}
}
