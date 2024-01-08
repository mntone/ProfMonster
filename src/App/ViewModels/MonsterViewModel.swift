import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject, Identifiable {
	private let monster: Monster
#if !os(watchOS)
	private let notifier: DebounceNotifier<String>
#endif

	@Published
	private(set) var state: StarSwingsState<MonsterDataViewModel>

	@Published
	var isFavorited: Bool {
		didSet {
			monster.isFavorited = isFavorited
		}
	}

#if os(watchOS)
	@Published
	var note: String
#else
	@Published
	var note: String {
		didSet {
			notifier.send(note)
		}
	}
#endif

	init(_ monster: Monster) {
		self.monster = monster

		let elementDisplay = monster.app?.settings.elementDisplay ?? .sign
		self.state = monster.state.mapData { physiology in
			MonsterDataViewModel(monster.id,
								 displayMode: elementDisplay,
								 rawValue: physiology)
		}
		self.isFavorited = monster.isFavorited
		self.note = monster.note

		// Send data
#if !os(watchOS)
		self.notifier = DebounceNotifier(interval: 5.0) { note in
			monster.note = note
		}
#endif

		// Receive data
		let scheduler = DispatchQueue.main
		monster.$state
			.dropFirst()
			.mapData { physiologies in
				MonsterDataViewModel(monster.id,
									 displayMode: elementDisplay,
									 rawValue: physiologies)
			}
			.receive(on: scheduler)
			.assign(to: &$state)
		monster.isFavoritedPublisher
			.dropFirst()
			.filter { [weak self] value in
				self?.isFavorited != value
			}
			.receive(on: scheduler)
			.assign(to: &$isFavorited)
		monster.notePublisher
			.dropFirst()
			.filter { [weak self] value in
				self?.note != value
			}
			.receive(on: scheduler)
			.assign(to: &$note)

		monster.fetchIfNeeded()
	}

#if !os(watchOS)
	deinit {
		if monster.note != note {
			monster.note = note
		}
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

	var readableName: String {
		@inline(__always)
		get {
			monster.readableName
		}
	}

	var sortkey: String {
		@inline(__always)
		get {
			monster.sortkey
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

// MARK: - Convenience Initializers

extension MonsterViewModel {
	convenience init?(id: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let monster = app.findMonster(by: id) else {
			app.logger.notice("Failed to get the monster (id: \(id))")
			return nil
		}
		self.init(monster)
	}

	convenience init?(id monsterID: String, for gameID: String) {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		guard let game = app.findGame(by: gameID),
			  let monster = game.findMonster(by: monsterID) else {
			app.logger.notice("Failed to get the monster (id: \(gameID):\(monsterID))")
			return nil
		}
		self.init(monster)
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
