import Foundation

final class MALanguageService: LanguageService, LanguageServiceInternal {
	private static let bundle = Bundle(for: MALanguageService.self)

	private let _separator: String
	private let _textProcessor: TextProcessor

	private let _monsters: [String: MHLocalizationMonster]
	private let _states: [String: String]

	let localeKey: String
	let locale: Locale


	init(localeKey: String, localization: MHLocalization)  {
		self.localeKey = localeKey
		self.locale = Locale(identifier: localeKey)

		self._separator = String(localized: "SEPARATOR", bundle: Self.bundle, locale: locale)
		self._textProcessor = LanguageUtil.getPreferredTextProcessor(self.localeKey)

		self._monsters = localization.monsters.reduce(into: [:]) { output, monster in
			output[monster.id] = monster
		}
		self._states = localization.states
	}

	func normalize(forSearch searchText: String) -> String {
		searchText.isEmpty
			? searchText
			: _textProcessor.normalize(forSearch: searchText)
	}

	func normalize(fromReadable readableText: String) -> String {
		readableText
	}

	func readable(from text: String) -> String {
		_textProcessor.readable(from: text)
	}

	func latin(from readableText: String) -> String {
		_textProcessor.latin(from: readableText)
	}

	func sortkey(from readableText: String) -> String {
		_textProcessor.sortkey(from: readableText)
	}

	func getLocalizedKeywords(of key: Attack) -> [String] {
		String(localized: String.LocalizationValue("KEYWORDS_" + key.rawValue.uppercased()), bundle: Self.bundle, locale: locale)
			.split(separator: ",")
			.map(String.init)
	}

	func getLocalizedString(of key: String, for type: LanguageDictionary) -> String {
		switch type {
		case .monster:
			if let val = _monsters[key] {
				return val.name
			} else {
				return key.replacingOccurrences(of: "_", with: " ").capitalized
			}
		case .part:
			return String(localized: String.LocalizationValue(key), table: "Parts", bundle: Self.bundle, locale: locale)
		case .state:
			if let val = _states[key] {
				return val
			} else {
				return key.replacingOccurrences(of: "_", with: " ").capitalized
			}
		}
	}

	func getLocalizedJoinedString(of keys: [String], for type: LanguageDictionary) -> String {
		keys
			.map { key in
				getLocalizedString(of: key, for: type)
			}
			.joined(separator: _separator)
	}

	func getMonster(of key: String) -> MHLocalizationMonster? {
		_monsters[key]
	}
}
