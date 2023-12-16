import Foundation

enum MonsterLocalizationMapper {
	static func map(_ src: MHLocalizationMonster, languageService: LanguageService) -> [String] {
		var result: [String] = []
		result.append(languageService.normalize(src.name))

#if !os(watchOS)
		let latinName = languageService.latin(from: src.name)
		if src.name != latinName {
			result.append(latinName)
		}
#endif

		if let anotherName = src.anotherName {
			result.append(languageService.normalize(anotherName))
		}
		result.append(contentsOf: src.keywords.map(languageService.normalize))

		return result
	}
}
