import Foundation

public protocol TextProcessor {
	func normalize(_ text: String) -> String
	func latin(from text: String) -> String
}

struct DefaultTextProcessor: TextProcessor {
	init() {
	}

	func normalize(_ text: String) -> String {
		text.lowercased()
	}

	func latin(from text: String) -> String {
		text
	}
}
