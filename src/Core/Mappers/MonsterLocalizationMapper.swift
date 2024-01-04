import Foundation

enum MonsterLocalizationMapper {
	static func map(_ src: MHLocalizationMonster,
					readableName: String,
					languageService: LanguageService) -> [String] {
		var result: [String] = []
		result.append(languageService.normalize(fromReadable: readableName))

#if !os(watchOS)
		let latinName = languageService.latin(from: readableName)
		if src.name != latinName {
			result.append(latinName)
		}
#endif

		if let anotherName = src.anotherName {
			result.append(languageService.normalize(fromReadable: anotherName))
		}
		result.append(contentsOf: src.keywords.map(languageService.normalize(fromReadable:)))

		return result
	}
}
