import Foundation

enum LanguageUtil {
	static func getPreferredLanguageKey<C>(_ keys: C) -> String where C: Collection, C.Element == String {
		guard !keys.isEmpty else {
			fatalError()
		}

		let langs = Locale.preferredLanguages
		for lang in langs {
			if keys.contains(lang) {
				return lang
			}

			// Try to remove hyphen (-)
			if let index = lang.lastIndex(of: "-") {
				let prefixLang = String(lang[..<index])
				if keys.contains(prefixLang) {
					return prefixLang
				}
			}
		}

		// Try English
		if keys.contains("en") {
			return "en"
		}

		// Return first keys
		return keys.first!
	}

	static func getPreferredTextProcessor(_ lang: String) -> TextProcessor {
		switch lang {
		case "ja":
			return JapaneseTextProcessor()
		case "zh":
			return ChineseTextProcessor()
		case "ko":
			return KoreanTextProcessor()
		default:
			return DefaultTextProcessor()
		}
	}
}
