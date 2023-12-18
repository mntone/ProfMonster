import Combine
import Foundation

public enum LanguageDictionary {
	case part
	case state
}

public protocol LanguageService {
	var localeKey: String { get }
	var locale: Locale { get }

	func normalize(_ text: String) -> String
	func latin(from text: String) -> String

	func register(dictionary: [String: String], for type: LanguageDictionary)
	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String
	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String
}

final class PassthroughtLanguageService: LanguageService {
	let locale: Locale = Locale(identifier: "en")
	var dictionaries: [LanguageDictionary: [String: String]] = [:]

	public init() {
	}

	var localeKey: String {
		"en"
	}

	func normalize(_ text: String) -> String {
		text
	}

	func latin(from text: String) -> String {
		text
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
