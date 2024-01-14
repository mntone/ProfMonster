import Combine

public final class Monster: FetchableEntity<Physiologies>, Entity {
	private let _physiologyMapper: PhysiologyMapper
	private let _userDatabase: UserDatabase

	private let _syncLock: Lock = LockUtil.create()
	private var _syncing: Bool = false

	private let isFavoritedSubject: CurrentValueSubject<Bool, Never>
	private let noteSubject: CurrentValueSubject<String, Never>

	public weak var app: App?

	public let id: String
	public let type: String
	public let weaknesses: [String: Weakness]?
	public let name: String
	public let readableName: String
	public let sortkey: String
	public let anotherName: String?
	public let keywords: [String]

	public var isFavorited: Bool {
		@inline(__always)
		get {
			isFavoritedSubject.value
		}
		set {
			isFavoritedSubject.value = newValue
			uploadValue()
		}
	}

	public var isFavoritedPublisher: AnyPublisher<Bool, Never> {
		@inline(__always)
		get {
			isFavoritedSubject.eraseToAnyPublisher()
		}
	}

	public var note: String {
		@inline(__always)
		get {
			noteSubject.value
		}
		set {
			noteSubject.value = newValue
			uploadValue()
		}
	}

	public var notePublisher: AnyPublisher<String, Never> {
		@inline(__always)
		get {
			noteSubject.eraseToAnyPublisher()
		}
	}

	private var cancellable: AnyCancellable?

	init(app: App,
		 id: String,
		 monster: MHGameMonster,
		 dataSource: DataSource,
		 languageService: LanguageService,
		 physiologyMapper: PhysiologyMapper,
		 localization: MHLocalizationMonster,
		 userDatabase: UserDatabase,
		 userData: UDMonster?,
		 prefix: String,
		 reference: [Monster]) {
		self.app = app
		self._physiologyMapper = physiologyMapper
		self._userDatabase = userDatabase

		self.id = id
		self.type = monster.type
		self.weaknesses = monster.weakness?.compactMapValues(Weakness.init(string:))
		self.name = localization.name

		let readableName = localization.readableName ?? languageService.readable(from: localization.name)
		self.readableName = readableName
		if app.settings.linkSubspecies,
		   let linkedID = monster.linkedID.map({ prefix + $0 }),
		   let linkedIndex = monster.linkedIndex,
		   let referenceMonster = reference.last(where: { $0.id == linkedID }) {
			self.sortkey = referenceMonster.sortkey + String(linkedIndex)
		} else {
			self.sortkey = languageService.sortkey(from: readableName)
		}
		self.anotherName = localization.anotherName
		self.keywords = MonsterLocalizationMapper.map(localization,
													  readableName: readableName,
													  weaknesses: weaknesses,
													  languageService: languageService)

		if let userData {
			self.isFavoritedSubject = CurrentValueSubject(userData.isFavorited)
			self.noteSubject = CurrentValueSubject(userData.note)
		} else {
			self.isFavoritedSubject = CurrentValueSubject(false)
			self.noteSubject = CurrentValueSubject("")
		}

#if DEBUG
		super.init(dataSource: dataSource, delayed: app.delayRequest)
#else
		super.init(dataSource: dataSource)
#endif

		self.cancellable = userDatabase.observeChange(of: id).sink { [weak self] change in
			guard let self else { return }

			defer {
				self._syncLock.withLock {
					self._syncing = false
				}
			}
			self._syncLock.withLock {
				self._syncing = true
			}

			switch change {
			case .add:
				guard let userData = userDatabase.getMonster(by: id) else { return }
				self.isFavorited = userData.isFavorited
				self.note = userData.note
			case let .update(names):
				guard let userData = userDatabase.getMonster(by: id) else { return }
				names.forEach { name in
					switch name {
					case "isFavorited":
						if self.isFavorited != userData.isFavorited {
							self.isFavoritedSubject.value = userData.isFavorited
						}
					case "note":
						if self.note != userData.note {
							self.noteSubject.value = userData.note
						}
					default:
						break
					}
				}
			case .delete:
				self.isFavorited = false
				self.note = ""
			}
		}
	}

	override func _fetch() async throws -> Physiologies {
		let ids = id.split(separator: ":", maxSplits: 1).map(String.init)
		assert(ids.count == 2)

		let monster = try await _dataSource.getMonster(of: ids[1], for: ids[0])
		if Task.isCancelled {
			throw StarSwingsError.cancelled
		}

		let options = PhysiologyMapperOptions(mergeParts: app?.settings.mergeParts ?? true)
		let physiologies = _physiologyMapper.map(json: monster, options: options)
		return physiologies
	}

	private func uploadValue() {
		let syncing = _syncLock.withLock {
			_syncing
		}
		guard !syncing else { return }

		let trasientMonster = UDMonster(id: id,
										isFavorited: isFavorited,
										note: note)
		_userDatabase.update(trasientMonster)
	}
}

// MARK: - Equatable

extension Monster: Equatable {
	public static func ==(lhs: Monster, rhs: Monster) -> Bool {
		lhs.id == rhs.id
	}
}
