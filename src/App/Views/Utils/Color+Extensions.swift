import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Color {
#if os(macOS)
	static let separator = Color(NSColor.gray)
	static let systemGroupedBackground = Color(NSColor.windowBackgroundColor)
	static let secondarySystemGroupedBackground = Color(NSColor.white)

#elseif os(watchOS)
	static let separator = Color(white: 1, opacity: 0.12)

#else
	static let separator = Color(UIColor.separator)
	static let systemGroupedBackground = Color(UIColor.systemGroupedBackground)
	static let secondarySystemGroupedBackground = Color(UIColor.secondarySystemGroupedBackground)
#endif
}
