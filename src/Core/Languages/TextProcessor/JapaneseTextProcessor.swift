import Foundation

public struct JapaneseTextProcessor: TextProcessor {
	public init() {
	}

	public func normalize(_ text: String) -> String {
		text.lowercased()
			.applyingTransform(.hiraganaToKatakana, reverse: false)!
			.decomposedStringWithCompatibilityMapping  // NFKD
	}

	public func latin(from text: String) -> String {
		text.precomposedStringWithCompatibilityMapping  // NFKC
			.applyingTransform(.latinToKatakana, reverse: true)!
	}
}
