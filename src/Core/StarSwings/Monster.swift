import Combine

public final class Monster: FetchableEntity<Physiologies>, Entity {
	private let _physiologyMapper: PhysiologyMapper
	private let _userDatabase: UserDatabase

	private let _syncLock: Lock = LockUtil.create()
	private var _syncing: Bool = false

	public weak var app: App?

	public let id: String
	public let type: String
	public let rawID: String
	public let gameID: String
	public let name: String
	public let sortkey: String?
	public let anotherName: String?
	public let keywords: [String]

	@Published
	public var isFavorited: Bool {
		didSet {
			uploadValue()
		}
	}

	@Published
	public var note: String {
		didSet {
			uploadValue()
		}
	}

	private var cancellable: AnyCancellable?

	init(app: App,
		 id: String,
		 type: String,
		 gameID: String,
		 dataSource: DataSource,
		 languageService: LanguageService,
		 physiologyMapper: PhysiologyMapper,
		 localization: MHLocalizationMonster,
		 userDatabase: UserDatabase,
		 userData: UDMonster?) {
		self.app = app
		self._physiologyMapper = physiologyMapper
		self._userDatabase = userDatabase

		let myid = "\(gameID):\(id)"
		self.id = myid
		self.type = type
		self.rawID = id
		self.gameID = gameID
		self.name = localization.name
		self.sortkey = localization.sortkey
		self.anotherName = localization.anotherName
		self.keywords = MonsterLocalizationMapper.map(localization, languageService: languageService)

		if let userData {
			self.isFavorited = userData.isFavorited
			self.note = userData.note
		} else {
			self.isFavorited = false
			self.note = ""
		}

		super.init(dataSource: dataSource)

		self.cancellable = userDatabase.observeChange(of: myid).sink { [weak self] change in
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
				guard let userData = userDatabase.getMonster(by: myid) else { return }
				self.isFavorited = userData.isFavorited
				self.note = userData.note
			case let .update(names):
				guard let userData = userDatabase.getMonster(by: myid) else { return }
				names.forEach { name in
					switch name {
					case "isFavorited":
						if self.isFavorited != userData.isFavorited {
							self.isFavorited = userData.isFavorited
						}
					case "note":
						if self.note != userData.note {
							self.note = userData.note
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
		let monster = try await _dataSource.getMonster(of: rawID, for: gameID)
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
