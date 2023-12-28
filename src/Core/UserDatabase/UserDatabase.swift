import Combine

public enum UDChange {
	case add
	case update(_: [String])
	case delete
}

public protocol UserDatabase {
	func ensureState()

	func getMonsters(by prefixID: String) -> [UDMonster]
	func getMonster(by id: String) -> UDMonster?
	func update(_ monster: UDMonster)

	func observeChange(of monsterID: String) -> AnyPublisher<UDChange, Never>
}
