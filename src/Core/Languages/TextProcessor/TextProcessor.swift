import Foundation

public protocol TextProcessor {
	func normalize(_ text: String) -> String
	func latin(from text: String) -> String
}

public struct DefaultTextProcessor: TextProcessor {
	public init() {
	}
	
	public func normalize(_ text: String) -> String {
		text
	}
	
	public func latin(from text: String) -> String {
		text
	}
}
