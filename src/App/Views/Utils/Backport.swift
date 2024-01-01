import SwiftUI

public struct Backport<Content> {
	public let content: Content
}

public extension ShapeStyle {
	var backport: Backport<Self> {
		Backport(content: self)
	}
}

public extension View {
	var backport: Backport<Self> {
		Backport(content: self)
	}
}
