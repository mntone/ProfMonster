import Foundation

struct KoreanTextProcessor: TextProcessor {
	init() {
	}

	func normalize(_ text: String) -> String {
		text.lowercased()
	}

	func latin(from text: String) -> String {
		text.applyingTransform(.latinToHangul, reverse: true)!
	}
}
