import SwiftUI

#if os(macOS)
import AppKit
#else
import class UIKit.UIColor
#endif

extension Color {
#if os(iOS)
	static var chromeShadow: Color = {
		guard let systemChromeShadowColor = UIColor.value(forKey: "_systemChromeShadowColor") as? UIColor else {
			return Color(white: 1, opacity: 0.15)
		}
		return .fallbackChromeShadow
	}()
#endif
}
