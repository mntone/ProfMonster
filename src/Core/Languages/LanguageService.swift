import Combine
import Foundation

public enum LanguageDictionary {
	case state
}

public protocol LanguageService {
	var locale: String { get }

	func normalize(_ text: String) -> String
	func latin(from text: String) -> String

	func register(dictionary: [String: String], for type: LanguageDictionary)
	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String
}

final class PassthroughtLanguageService: LanguageService {
	var dictionaries: [LanguageDictionary: [String: String]] = [:]

	public init() {
	}

	var locale: String {
		"en"
	}

	func normalize(_ text: String) -> String {
		text
	}

	func latin(from text: String) -> String {
		text
	}

	func register(dictionary: [String: String], for type: LanguageDictionary) {
		dictionaries[type] = dictionary
	}

	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String {
		if let dict = dictionaries[type],
		   let val = dict[key] {
			return val
		} else {
			return key
		}
	}
}
