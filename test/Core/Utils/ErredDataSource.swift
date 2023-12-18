import Combine
import Foundation
import MonsterAnalyzerCore

enum ErrorOfferLevel {
	case config
	case game
	case monster
	case none
}

final class ErredDataSource: MHDataSource {
	let dataSource: MHDataSource

	var error: Error
	var errorLevel: ErrorOfferLevel

	init(dataSource: MHDataSource,
		 error: Error = StarSwingsError.notExist,
		 errorLevel: ErrorOfferLevel = .none) {
		self.dataSource = dataSource
		self.error = error
		self.errorLevel = errorLevel
	}

	func getConfig() -> AnyPublisher<MHConfig, Error> {
		switch errorLevel {
		case .config:
			Fail(outputType: MHConfig.self, failure: error)
				.eraseToAnyPublisher()
		case .game, .monster, .none:
			dataSource.getConfig()
		}
	}

	func getGame(of titleId: String) -> AnyPublisher<MHGame, Error> {
		switch errorLevel {
		case .config, .game:
			Fail(outputType: MHGame.self, failure: error)
				.eraseToAnyPublisher()
		case .monster, .none:
			dataSource.getGame(of: titleId)
		}
	}

	func getLocalization(of key: String, for titleId: String) -> AnyPublisher<MHLocalization, Error> {
		dataSource.getLocalization(of: key, for: titleId)
	}

	func getMonster(of id: String, for titleId: String) -> AnyPublisher<MHMonster, Error> {
		switch errorLevel {
		case .config, .game, .monster:
			Fail(outputType: MHMonster.self, failure: error)
				.eraseToAnyPublisher()
		case .none:
			dataSource.getMonster(of: id, for: titleId)
		}
	}
}
