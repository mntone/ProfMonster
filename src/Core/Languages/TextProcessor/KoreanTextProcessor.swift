import Foundation

public struct KoreanTextProcessor: TextProcessor {
	public init() {
	}

	public func normalize(_ text: String) -> String {
		text.lowercased()
	}

	public func latin(from text: String) -> String {
		text.applyingTransform(.latinToHangul, reverse: true)!
	}
}
