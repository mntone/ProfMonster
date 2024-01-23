import SwiftUI
import class UIKit.UIColor

extension Color {
	static var chromeShadow: Color = {
		guard let systemChromeShadowColor = UIColor.value(forKey: "_systemChromeShadowColor") as? UIColor else {
			return Color(white: 1, opacity: 0.15)
		}
		return .fallbackChromeShadow
	}()
}
