import Foundation

final class MALanguageService: LanguageService {
	private let _textProcessor: TextProcessor

	let locale: String

	var dictionaries: [LanguageDictionary: [String: String]] = [:]

	init<C>(_ keys: C) where C: Collection, C.Element == String {
		self.locale = LanguageUtil.getPreferredLanguageKey(keys)
		self._textProcessor = LanguageUtil.getPreferredTextProcessor(self.locale)
	}

	func normalize(_ text: String) -> String {
		_textProcessor.normalize(text)
	}

	func latin(from text: String) -> String {
		_textProcessor.latin(from: text)
	}

	func register(dictionary: [String: String], for type: LanguageDictionary) {
		dictionaries[type] = dictionary
	}

	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String {
		if let dict = dictionaries[type],
		   let val = dict[key] {
			return val
		} else {
			return key.replacingOccurrences(of: "_", with: " ").capitalized
		}
	}
}
