import Foundation

public struct ChineseTextProcessor: TextProcessor {
	public init() {
	}
	
	public func normalize(_ text: String) -> String {
		text.decomposedStringWithCompatibilityMapping // NFKD
	}
	
	public func latin(from text: String) -> String {
		text.applyingTransform(.mandarinToLatin, reverse: false)!
			.folding(options: .diacriticInsensitive, locale: nil)
			.replacingOccurrences(of: " ", with: "")
	}
}
