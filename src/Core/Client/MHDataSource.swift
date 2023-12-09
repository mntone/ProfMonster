import Combine
import Foundation

public protocol MHDataSource {
	func getConfig() -> AnyPublisher<MHConfig, Error>
	func getGame(of titleId: String) -> AnyPublisher<MHGame, Error>
	func getLocalization(of key: String, for titleId: String) -> AnyPublisher<MHLocalization, Error>
	func getMonster(of id: String, for titleId: String) -> AnyPublisher<MHMonster, Error>
}
