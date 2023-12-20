import Foundation

struct JapaneseTextProcessor: TextProcessor {
	public init() {
	}

	func normalize(_ text: String) -> String {
		text.lowercased()
			.applyingTransform(.hiraganaToKatakana, reverse: false)!
			.decomposedStringWithCompatibilityMapping  // NFKD
	}

	func latin(from text: String) -> String {
		text.replacingOccurrences(of: "亜種$", with: "アシュ", options: .regularExpression)
			.replacingOccurrences(of: "希少種$", with: "キショウシュ", options: .regularExpression)
			.precomposedStringWithCompatibilityMapping  // NFKC
			.applyingTransform(.latinToKatakana, reverse: true)!
	}
}
