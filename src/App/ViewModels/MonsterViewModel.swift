import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject, Identifiable {
	private let monster: Monster

	let elementDisplay: WeaknessDisplayMode

	@Published
	private(set) var state: StarSwingsState<MonsterDataViewModel>

	init(_ monster: Monster) {
		self.monster = monster
		self.elementDisplay = monster.app?.settings.elementDisplay ?? .sign
		self.state = monster.state.mapData(MonsterDataViewModel.init(rawValue:))
		monster.$state
			.dropFirst()
			.mapData { physiologies in
				MonsterDataViewModel(rawValue: physiologies)
			}
			.receive(on: DispatchQueue.main)
			.assign(to: &$state)

		monster.fetchIfNeeded()
	}

	convenience init?(id monsterID: String, for gameID: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let monster = app.findMonster(by: monsterID, of: gameID) else {
			// TODO: Logging. Game is not found
			return nil
		}
		self.init(monster)
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
