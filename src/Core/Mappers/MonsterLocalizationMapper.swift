import Foundation

enum MonsterLocalizationMapper {
	static func map(_ src: MHLocalizationMonster,
					readableName: String,
					weaknesses: [String: Weakness]?,
					languageService: LanguageServiceInternal) -> [String] {
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

		if let weaknesses {
			let weaknessAttacks = Set(weaknesses.values.flatMap { weakness in
				var result: [Attack] = []
				if weakness.fire == .mostEffective {
					result.append(.fire)
				}
				if weakness.water == .mostEffective {
					result.append(.water)
				}
				if weakness.thunder == .mostEffective {
					result.append(.thunder)
				}
				if weakness.ice == .mostEffective {
					result.append(.ice)
				}
				if weakness.dragon == .mostEffective {
					result.append(.dragon)
				}
				return result
			})
			let weaknessKeywords = weaknessAttacks.flatMap(languageService.getLocalizedKeywords(of:))
			result.append(contentsOf: weaknessKeywords)
		}

		return result
	}
}
