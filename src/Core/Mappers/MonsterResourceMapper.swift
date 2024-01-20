import Foundation

struct MonsterResourceMapper {
	let languageService: LanguageServiceInternal
#if os(iOS)
	let pad: Bool
#endif

	func getMonsterResource(_ key: String) -> MHLocalizationMonster? {
		languageService.getMonster(of: key)
	}

	func getReadableName(_ originalName: String) -> String {
		languageService.readable(from: originalName)
	}

	func getSortkey(_ readableName: String) -> String {
		languageService.sortkey(from: readableName)
	}

	func getLocalizedWeaknesses(_ weaknesses: [String: String]) -> [String: Weakness] {
		Dictionary(uniqueKeysWithValues: weaknesses.compactMap { key, value in
			let localizedStateName = languageService.getLocalizedString(of: key, for: .state)
			guard let weakness = Weakness(state: localizedStateName, string: value) else {
				return nil
			}
			return (key, weakness)
		})
	}

	func getKeywords(_ src: MHLocalizationMonster,
					 readableName: String,
					 weaknesses: [String: Weakness]?) -> [String] {
		var result: [String] = []

		let normalizedName = languageService.normalize(forSearch: src.name)
		result.append(normalizedName)

		let normalizedReadableName = languageService.normalize(fromReadable: readableName)
		if normalizedName != normalizedReadableName {
			result.append(normalizedReadableName)
		}

#if os(iOS)
		if pad {
			let latinName = languageService.latin(from: readableName)
			if normalizedReadableName != latinName {
				result.append(latinName)
			}
		}
#endif
#if os(macOS)
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
