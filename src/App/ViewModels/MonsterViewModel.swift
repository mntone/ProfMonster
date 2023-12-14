import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject, Identifiable {
	private let monster: Monster

	@Published
	private(set) var state: StarSwingsState = .ready

	@Published
	var data: MHMonster!

	init(_ monster: Monster) {
		self.monster = monster
		monster.$state.receive(on: DispatchQueue.main).assign(to: &$state)
		monster.$data.receive(on: DispatchQueue.main).assign(to: &$data)
	}

	convenience init?(id monsterID: String, for gameID: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let game = app.findGame(by: gameID),
			  let monster = game.findMonster(by: monsterID) else {
			// TODO: Logging. Game is not found
			return nil
		}
		self.init(monster)
	}

	func fetchData() {
		monster.fetchIfNeeded()
	}

	var id: String {
		@inline(__always)
		get {
			monster.id
		}
	}

	var gameID: String {
		@inline(__always)
		get {
			monster.gameID
		}
	}

	var name: String {
		@inline(__always)
		get {
			monster.name
		}
	}

	var anotherName: String? {
		@inline(__always)
		get {
			monster.anotherName
		}
	}

	var keywords: [String] {
		@inline(__always)
		get {
			monster.keywords
		}
	}
}

// MARK: - Equatable

extension MonsterViewModel: Equatable {
	static func == (lhs: MonsterViewModel, rhs: MonsterViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Hashable

extension MonsterViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
