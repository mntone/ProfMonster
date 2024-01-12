import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject {
	private let app: App

	private var monster: Monster?
	private var task: Task<Void, Never>?

	@Published
	private(set) var state: RequestState = .ready

	@Published
	private(set) var item: MonsterDataViewModel? = nil

	@Published
	var isFavorited: Bool = false {
		didSet {
			monster?.isFavorited = isFavorited
		}
	}

#if os(watchOS)
	@Published
	var note: String = ""
#else
	private var notifier: DebounceNotifier<String>? = nil

	@Published
	var note: String = "" {
		didSet {
			notifier?.send(note)
		}
	}
#endif

	init() {
		guard let app = MAApp.resolver.resolve(App.self) else {
			fatalError()
		}
		self.app = app
	}

#if !os(watchOS)
	deinit {
		notifier = nil
		flush()
	}
#endif

	func set(domain monster: Monster) {
		self.monster = nil

		monster.fetchIfNeeded()

		// Load current data.
		let elementDisplay = app.settings.elementDisplay
		switch monster.state {
		case .ready:
			state = .ready
		case .loading:
			state = .loading
		case let .complete(data: physiology):
			state = .complete
			item = MonsterDataViewModel(monster.id,
										displayMode: elementDisplay,
										rawValue: physiology)
		case let .failure(date, error):
			state = .failure(date: date, error: error)
			item = nil
		}

		self.isFavorited = monster.isFavorited
		self.note = monster.note

		let scheduler = DispatchQueue.main
		monster.$state.removeData().receive(on: scheduler).assign(to: &$state)

		monster.$state
			.dropFirst()
			.map { state -> MonsterDataViewModel? in
				switch state {
				case let .complete(data: physiology):
					MonsterDataViewModel(monster.id,
										 displayMode: elementDisplay,
										 rawValue: physiology)
				default:
					nil
				}
			}
			.receive(on: scheduler)
			.assign(to: &$item)

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

		// Set current
		self.monster = monster

#if !os(watchOS)
		self.notifier = DebounceNotifier(interval: 3.0) { note in
			monster.note = note
		}
#endif
	}

	var isDisabled: Bool {
		@inline(__always)
		get {
			monster == nil || !state.isComplete
		}
	}

	var name: String? {
		@inline(__always)
		get {
			monster?.name
		}
	}

	var anotherName: String? {
		@inline(__always)
		get {
			monster?.anotherName
		}
	}

	var pairs: [(String, String)] {
		@inline(__always)
		get {
			guard let monster else { return [] }

			return [
				("ID", monster.id),
				("Type", monster.type),
				("Name", monster.name),
				("Readable Name", monster.readableName),
				("Sortkey", monster.sortkey),
				("Another Name", monster.anotherName ?? "None"),
				("Keywords", monster.keywords.joined(separator: ", "))
			]
		}
	}

#if !os(watchOS)
	private func flush() {
		if let monster,
		   monster.note != note {
			monster.note = note
		}
	}
#endif
}

// MARK: - Set data

extension MonsterViewModel {
	func set() {
		if let task {
			self.task = nil
			task.cancel()
		}

#if !os(watchOS)
		notifier = nil
		flush()
#endif

		monster = nil
		state = .ready
		item = nil
		isFavorited = false
		note = ""
	}

	@inline(__always)
	func set(id: String) {
		guard monster?.id != id else {
			return
		}

		if let task {
			self.task = nil
			task.cancel()
		}

#if !os(watchOS)
		notifier = nil
		flush()
#endif

		if let monster = app.findMonster(by: id) {
			set(domain: monster)
			return
		}

		self.task = Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return }

			guard let monster = await app.prefetch(monsterOf: id) else {
				app.logger.notice("Failed to get the monster (id: \(id))")
				return
			}

			DispatchQueue.main.async {
				self.set(domain: monster)
			}
		}
	}

	@inline(__always)
	func set(id: String?) async {
		if let id {
			await set(id: id)
		} else {
			set()
		}
	}
}
