import Foundation
import MonsterAnalyzerCore

final class GameItemViewModel: ObservableObject, Identifiable {
	private let monster: Monster

	@Published
	var isFavorited: Bool {
		didSet {
			monster.isFavorited = isFavorited
		}
	}

	init(_ monster: Monster) {
		self.monster = monster
		self.isFavorited = monster.isFavorited

		// Receive data
		let scheduler = DispatchQueue.main
		monster.isFavoritedPublisher
			.dropFirst()
			.filter { [weak self] value in
				self?.isFavorited != value
			}
			.receive(on: scheduler)
			.assign(to: &$isFavorited)
	}

#if DEBUG || targetEnvironment(simulator)
	convenience init?(id: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let monster = app.findMonster(by: id) else {
			// TODO: Logging. Game is not found
			return nil
		}
		self.init(monster)
	}
#endif

	var id: String {
		@inline(__always)
		get {
			monster.id
		}
	}

	var type: String {
		@inline(__always)
		get {
			monster.type
		}
	}

	var name: String {
		@inline(__always)
		get {
			monster.name
		}
	}

	var keywords: [String] {
		@inline(__always)
		get {
			monster.keywords
		}
	}

	private var sortkey: String {
		@inline(__always)
		get {
			monster.sortkey
		}
	}
}

extension GameItemViewModel: Equatable {
	static func == (lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

extension GameItemViewModel: Comparable {
	static func <(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.sortkey < rhs.sortkey
	}
}
