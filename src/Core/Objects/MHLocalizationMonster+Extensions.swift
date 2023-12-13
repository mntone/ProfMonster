import Foundation

public extension MHLocalizationMonster {
	func getAllKeywords() -> [String] {
		var result: [String] = []
		result.append(LanguageUtil.textProcessor.normalize(name))
		
		let latinName = LanguageUtil.textProcessor.latin(from: name)
		if name != latinName {
			result.append(latinName)
		}

		if let anotherName {
			result.append(LanguageUtil.textProcessor.normalize(anotherName))
		}
		result.append(contentsOf: keywords.map(LanguageUtil.textProcessor.normalize))
		
		debugPrint(result)
		return result
	}
}
