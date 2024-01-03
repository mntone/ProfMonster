import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject, Identifiable, FavoriteViewModel {
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
