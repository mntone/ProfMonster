import Foundation

public enum LanguageUtil {
	public static func getPreferredLanguageKey(_ keys: [String]) -> String {
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
		return keys[0]
	}
}
