import Foundation

enum MonsterLocalizationMapper {
	static func map(_ src: MHLocalizationMonster,
					readableName: String,
					languageService: LanguageService) -> [String] {
		var result: [String] = []

		let normalizedName = languageService.normalize(forSearch: src.name)
		result.append(normalizedName)

		let normalizedReadableName = languageService.normalize(fromReadable: readableName)
		if normalizedName != normalizedReadableName {
			result.append(normalizedReadableName)
		}

#if !os(watchOS)
		let latinName = languageService.latin(from: readableName)
		if normalizedReadableName != latinName {
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
