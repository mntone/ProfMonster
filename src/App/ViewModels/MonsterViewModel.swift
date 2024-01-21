import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject {
	private let app: App

	private var monster: Monster?
	private var cancellable: AnyCancellable?
	private var task: Task<Void, Never>?

	private(set) var state: RequestState = .ready

	private(set) var items: [MonsterDataViewModel] = [] {
		didSet {
			guard !items.isEmpty else {
				selectedItem = nil
				return
			}

			if app.settings.selectedMasterOrG {
				selectedItem = items.first(where: \.mode.isMasterOrG) ?? items.first
			} else {
				selectedItem = items.first
			}
		}
	}

	@Published
	var selectedItem: MonsterDataViewModel? {
		didSet {
			if let selectedItem {
				app.settings.selectedMasterOrG = selectedItem.mode.isMasterOrG
			}
		}
	}

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

	// Reset current states.
	private func resetState() {
		self.monster = nil
		if let cancellable {
			self.cancellable = nil
			cancellable.cancel()
		}
		if let task {
			self.task = nil
			task.cancel()
		}

#if !os(watchOS)
		notifier = nil
		flush()
#endif
	}

	func set(domain monster: Monster) {
		resetState()
		monster.fetchIfNeeded()

		// Load data from domain.
		let scheduler = DispatchQueue.main
		let elementDisplay = app.settings.elementDisplay
		cancellable = monster.$state
			.receive(on: scheduler)
			.sink { [weak self] state in
				guard let self else { return }
				switch state {
				case .ready, .loading:
					if self.state != .loading {
						self.state = .loading

						if let weaknesses = monster.weaknesses {
							self.items = MonsterDataViewModelFactory.create(monster: monster,
																			displayMode: elementDisplay,
																			weaknesses: weaknesses)
						} else {
							self.items = []
						}
					}
				case let .complete(physiologies):
					self.state = .complete
					self.items = MonsterDataViewModelFactory.create(monster: monster,
																	displayMode: elementDisplay,
																	rawValue: physiologies)
				case let .failure(date, error):
					self.state = .failure(date: date, error: error)
					self.items = []
				}
			}

		monster.isFavoritedPublisher
			.filter { [weak self] value in
				self?.isFavorited != value
			}
			.receive(on: scheduler)
			.assign(to: &$isFavorited)

		monster.notePublisher
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

	var name: String {
		@inline(__always)
		get {
			monster?.name ?? ""
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
				("Size", monster.size.map { String(format: "%.2f", $0) } ?? "None"),
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
		resetState()

		state = .ready
		items = []
		selectedItem = nil
		isFavorited = false
		note = ""
	}

	@inline(__always)
	func set(id: String) {
		guard monster?.id != id else {
			return
		}

		if let monster = app.findMonster(by: id) {
			set(domain: monster)
			return
		}

		self.task = Task.detached(priority: .userInitiated) { [weak self] in
			guard let self else { return }

			guard let monster = try? await app.prefetch(monsterOf: id) else {
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
