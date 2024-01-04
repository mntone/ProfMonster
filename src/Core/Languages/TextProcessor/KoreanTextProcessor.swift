import Foundation

struct KoreanTextProcessor: TextProcessor {
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
		readableText.applyingTransform(.latinToHangul, reverse: true)!
	}

	func sortkey(from readableText: String) -> String {
		readableText.applyingTransform(.latinToHangul, reverse: true)!
	}
}
