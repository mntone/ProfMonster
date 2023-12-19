import Combine
import Foundation

public final class Monster: FetchableEntity, Entity {
	private let _languageService: LanguageService

	public let id: String
	public let gameID: String
	public let name: String
	public let anotherName: String?
	public let keywords: [String]

	@Published
	public var physiologies: Physiologies?

	init(_ id: String,
		 gameID: String,
		 dataSource: DataSource,
		 languageService: LanguageService,
		 localization: MHLocalizationMonster) {
		self._languageService = languageService

		self.id = id
		self.gameID = gameID
		self.name = localization.name
		self.anotherName = localization.anotherName
		self.keywords = MonsterLocalizationMapper.map(localization, languageService: languageService)
		super.init(dataSource: dataSource)
	}

	override func _fetch() async throws {
		let monster = try await _dataSource.getMonster(of: id, for: gameID)
		let physiologies = PhysiologyMapper.map(json: monster, languageService: _languageService)
		self.physiologies = physiologies
	}
}
