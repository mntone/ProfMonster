import Foundation

public enum LanguageDictionary {
	case monster
	case part
	case state
}

public protocol LanguageService {
	var localeKey: String { get }
	var locale: Locale { get }

	func normalize(forSearch searchText: String) -> String

	func getLocalizedKeywords(of key: Attack) -> [String]
	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String
	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String
}

protocol LanguageServiceInternal: LanguageService {
	func normalize(fromReadable readableText: String) -> String

	func readable(from text: String) -> String
	func latin(from readableText: String) -> String
	func sortkey(from readableText: String) -> String

	func getMonster(of key: String) -> MHLocalizationMonster?
}

final class PassthroughtLanguageService: LanguageService, LanguageServiceInternal {
	let locale: Locale = Locale(identifier: "en")

	init() {
	}

	var localeKey: String {
		"en"
	}

	func normalize(forSearch searchText: String) -> String {
		searchText
	}

	func normalize(fromReadable readableText: String) -> String {
		readableText
	}

	func readable(from text: String) -> String {
		text
	}

	func latin(from readableText: String) -> String {
		readableText
	}

	func sortkey(from readableText: String) -> String {
		readableText
	}

	func getLocalizedKeywords(of key: Attack) -> [String] {
		[key.rawValue.lowercased()]
	}

	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String {
		key
	}

	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String {
		keys.map { key in
			getLocalizedString(of: key, for: type)
		}.joined(separator: ", ")
	}

	func getMonster(of key: String) -> MHLocalizationMonster? {
		nil
	}
}
