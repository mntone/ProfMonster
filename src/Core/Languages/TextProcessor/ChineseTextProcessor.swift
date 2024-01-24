import Foundation

struct ChineseTextProcessor: TextProcessor {
	func normalize(forSearch searchText: String) -> String {
		searchText.lowercased()
	}

	func normalize(fromReadable readableText: String) -> String {
		readableText
	}

	func readable(from text: String) -> String {
		text.filter { char in
			!char.isWhitespace
		}
	}

	func latin(from readableText: String) -> String {
		readableText
			.applyingTransform(.mandarinToLatin, reverse: false)!
			.folding(options: .diacriticInsensitive, locale: nil)
	}

	func sortkey(from readableText: String) -> String {
		readableText
			.applyingTransform(.mandarinToLatin, reverse: false)!
			.filter { char in
				char != " "
			}
			.folding(options: .diacriticInsensitive, locale: nil)
	}
}
