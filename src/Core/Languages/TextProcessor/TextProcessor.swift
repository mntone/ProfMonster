import Foundation

public protocol TextProcessor {
	func normalize(forSearch searchText: String) -> String
	func normalize(fromReadable readableText: String) -> String

	func readable(from text: String) -> String
	func latin(from readableText: String) -> String
	func sortkey(from readableText: String) -> String
}

struct DefaultTextProcessor: TextProcessor {
	func normalize(forSearch searchText: String) -> String {
		searchText.lowercased()
	}

	func normalize(fromReadable readableText: String) -> String {
		readableText
	}

	func readable(from text: String) -> String {
		text.filter { char in
			!char.isWhitespace && char != "-"
		}.lowercased()
	}

	func latin(from readableText: String) -> String {
		readableText.folding(options: .diacriticInsensitive, locale: nil)
	}

	func sortkey(from readableText: String) -> String {
		readableText.folding(options: .diacriticInsensitive, locale: nil)
	}
}
