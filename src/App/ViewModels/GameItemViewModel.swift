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

	var size: Float32? {
		@inline(__always)
		get {
			monster.size
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

	var weaknesses: [String: Weakness]? {
		@inline(__always)
		get {
			monster.weaknesses
		}
	}

	fileprivate var sortkey: String {
		@inline(__always)
		get {
			monster.sortkey
		}
	}

	private var linkedSortkey: String {
		@inline(__always)
		get {
			monster.linkedSortkey
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
		lhs.linkedSortkey < rhs.linkedSortkey
	}
}

// MARK: - Sort using simple sortkey

enum AscendingSimpleSortkeyComparator {
	static func compare(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.sortkey < rhs.sortkey
	}
}

enum DescendingSimpleSortkeyComparator {
	static func compare(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.sortkey > rhs.sortkey
	}
}

#if !os(watchOS)

@available(watchOS, unavailable)
enum AscendingSizeComparator {
	static func compare(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.size.unsafelyUnwrapped < rhs.size.unsafelyUnwrapped
	}
}

@available(watchOS, unavailable)
enum DescendingSizeComparator {
	static func compare(lhs: GameItemViewModel, rhs: GameItemViewModel) -> Bool {
		lhs.size.unsafelyUnwrapped > rhs.size.unsafelyUnwrapped
	}
}

#endif
