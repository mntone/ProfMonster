import SwiftUI

public struct Backport<Content> {
	public let content: Content
}

public extension View {
	var backport: Backport<Self> {
		Backport(content: self)
	}
}
