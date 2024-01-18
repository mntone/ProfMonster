import Foundation

public enum MockMonsterKey: String, CaseIterable {
	case buchaCat = "bucha_cat"
	case guluQoo = "gulu_qoo"
}

public enum MockData {
	static func monster(_ key: MockMonsterKey) -> MHMonster? {
		let bundle = Bundle(for: NetworkDataSource.self)
		guard let url = bundle.url(forResource: key.rawValue, withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let json = try? JSONDecoder().decode(MHMonster.self, from: data) else {
			return nil
		}
		return json
	}

	public static func physiology(_ key: MockMonsterKey) -> Physiology? {
		guard let monster = Self.monster(key) else {
			return nil
		}

		let mapper = PhysiologyMapper(languageService: PassthroughtLanguageService())
		return mapper.map(json: monster, options: PhysiologyMapperOptions(mergeParts: false))
	}

}
