import Foundation

final class MALanguageService: LanguageService {
	private static let bundle = Bundle(for: MALanguageService.self)

	private let _textProcessor: TextProcessor

	let localeKey: String
	let locale: Locale
	let separator: String

	var dictionaries: [LanguageDictionary: [String: String]] = [:]

	init<C>(_ keys: C) where C: Collection, C.Element == String {
		self.localeKey = LanguageUtil.getPreferredLanguageKey(keys)
		self.locale = Locale(identifier: self.localeKey)
		self.separator = String(localized: String.LocalizationValue("/"), bundle: Self.bundle, locale: locale)
		self._textProcessor = LanguageUtil.getPreferredTextProcessor(self.localeKey)
	}

	func normalize(_ text: String) -> String {
		_textProcessor.normalize(text)
	}

	func latin(from text: String) -> String {
		_textProcessor.latin(from: text)
	}

	func register(dictionary: [String: String], for type: LanguageDictionary) {
		switch type {
		case .part:
			fatalError()
		case .state:
			dictionaries[type] = dictionary
		}
	}

	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String {
		switch type {
		case .part:
			return String(localized: String.LocalizationValue(key), bundle: Self.bundle, locale: locale)
		case .state:
			if let dict = dictionaries[type],
			   let val = dict[key] {
				return val
			} else {
				return key.replacingOccurrences(of: "_", with: " ").capitalized
			}
		}
	}

	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String {
		keys.map { key in
			getLocalizedString(of: key, for: type)
		}.joined(separator: separator)
	}
}
