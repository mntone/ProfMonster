import Foundation

public enum LanguageUtil {
	static let textProcessor: TextProcessor = {
		var lang = Locale.preferredLanguages[0]

		// Try to remove hyphen (-)
		if let index = lang.firstIndex(of: "-") {
			lang = String(lang[..<index])
		}

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
	}()

	public static func getPreferredLanguageKey<C>(_ keys: C) -> String where C: Collection, C.Element == String {
		guard !keys.isEmpty else {
			fatalError()
		}

		let langs = Locale.preferredLanguages
		for lang in langs {
			if keys.contains(lang) {
				return lang
			}

			// Try to remove hyphen (-)
			if let index = lang.firstIndex(of: "-") {
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
}
