import Combine
import Foundation
@testable import MonsterAnalyzerCore

enum ErrorOfferLevel {
	case config
	case game
	case monster
	case none
}

final class ErredDataSource: DataSource {
	let dataSource: DataSource

	var error: Error
	var errorLevel: ErrorOfferLevel

	init(dataSource: DataSource,
		 error: Error = StarSwingsError.notExists,
		 errorLevel: ErrorOfferLevel = .none) {
		self.dataSource = dataSource
		self.error = error
		self.errorLevel = errorLevel
	}

	func getConfig() async throws -> MHConfig {
		switch errorLevel {
		case .config:
			throw error
		case .game, .monster, .none:
			try await dataSource.getConfig()
		}
	}

	func getGame(of titleId: String) async throws -> MHGame {
		switch errorLevel {
		case .config, .game:
			throw error
		case .monster, .none:
			try await dataSource.getGame(of: titleId)
		}
	}

	func getLocalization(of key: String, for titleId: String) async throws -> MHLocalization {
		try await dataSource.getLocalization(of: key, for: titleId)
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		switch errorLevel {
		case .config, .game, .monster:
			throw error
		case .none:
			try await dataSource.getMonster(of: id, for: titleId)
		}
	}
}
