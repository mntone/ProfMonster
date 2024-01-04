import Foundation

public enum LanguageDictionary {
	case part
	case state
}

public protocol LanguageService {
	var localeKey: String { get }
	var locale: Locale { get }

	func normalize(forSearch searchText: String) -> String
	func normalize(fromReadable readableText: String) -> String

	func readable(from text: String) -> String
	func latin(from readableText: String) -> String
	func sortkey(from readableText: String) -> String

	func register(dictionary: [String: String], for type: LanguageDictionary)
	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String
	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String
}

final class PassthroughtLanguageService: LanguageService {
	let locale: Locale = Locale(identifier: "en")
	var dictionaries: [LanguageDictionary: [String: String]] = [:]

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
			return key
		case .state:
			if let dict = dictionaries[type],
			   let val = dict[key] {
				return val
			} else {
				return key
			}
		}
	}

	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String {
		keys.map { key in
			getLocalizedString(of: key, for: type)
		}.joined(separator: ", ")
	}
}
