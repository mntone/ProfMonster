import Combine
import Foundation

protocol DataSource {
	func getConfig() async throws -> MHConfig
	func getGame(of titleId: String) async throws -> MHGame
	func getLocalization(of key: String) async throws -> MHLocalization
	func getMonster(of id: String, for titleId: String) async throws -> MHMonster
}
