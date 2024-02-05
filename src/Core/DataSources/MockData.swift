import Foundation

public enum MockMonsterKey: String, CaseIterable {
#if DEBUG
	case buchaCat = "bucha_cat"
#endif
	case guluQoo = "gulu_qoo"
}

public enum MockData {
	static func localization(_ key: String) -> MHLocalization? {
		let bundle = Bundle(for: NetworkDataSource.self)
		guard let url = bundle.url(forResource: key, withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let json = try? JSONDecoder().decode(MHLocalization.self, from: data) else {
			return nil
		}
		return json
	}

	static func game() -> MHGame? {
		let bundle = Bundle(for: NetworkDataSource.self)
		guard let url = bundle.url(forResource: "index", withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let json = try? JSONDecoder().decode(MHGame.self, from: data) else {
			return nil
		}
		return json
	}

	static func monster(_ key: MockMonsterKey) -> MHMonster? {
		let bundle = Bundle(for: NetworkDataSource.self)
		guard let url = bundle.url(forResource: key.rawValue, withExtension: "json"),
			  let data = try? Data(contentsOf: url),
			  let json = try? JSONDecoder().decode(MHMonster.self, from: data) else {
			return nil
		}
		return json
	}

	public static func physiology(_ key: MockMonsterKey) -> Physiologies? {
		guard let monster = Self.monster(key) else {
			return nil
		}

		let mapper = PhysiologyMapper(languageService: PassthroughtLanguageService())
		return mapper.map(json: monster, options: PhysiologyMapperOptions(mergeParts: false))
	}

}
