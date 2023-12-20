import Foundation

struct ChineseTextProcessor: TextProcessor {
	init() {
	}

	func normalize(_ text: String) -> String {
		text.lowercased()
	}

	func latin(from text: String) -> String {
		text.applyingTransform(.mandarinToLatin, reverse: false)!
			.folding(options: .diacriticInsensitive, locale: nil)
			.replacingOccurrences(of: " ", with: "")
	}
}
