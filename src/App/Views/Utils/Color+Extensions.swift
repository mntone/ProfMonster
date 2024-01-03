import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension Color {
#if os(macOS)
	static let separator = Color(NSColor.gray)

#elseif os(watchOS)
	static let separator = Color(white: 1, opacity: 0.12)

#else
	static let separator = Color(UIColor.separator)
#endif
}
