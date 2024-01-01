import SwiftUI

// iOS 16, maybe buggy:
// https://qiita.com/SNQ-2001/items/b60d55c7436efff24a65
// TODO: Confirm actual implemenets on macOS 14
extension Backport where Content: ShapeStyle {
	var secondary: AnyShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			AnyShapeStyle(content.secondary)
		} else {
			AnyShapeStyle(content.opacity(0.5))
		}
	}

	var tertiary: AnyShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			AnyShapeStyle(content.tertiary)
		} else {
			AnyShapeStyle(content.opacity(0.25))
		}
	}

	var quaternary: AnyShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			AnyShapeStyle(content.quaternary)
		} else {
			AnyShapeStyle(content.opacity(0.2))
		}
	}

	var quinary: AnyShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			AnyShapeStyle(content.quinary)
		} else {
			AnyShapeStyle(content.opacity(0.175))
		}
	}

	func hierarchical(_ level: Int) -> AnyShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			switch level {
			case 1:
				AnyShapeStyle(content.secondary)
			case 2:
				AnyShapeStyle(content.tertiary)
			case 3:
				AnyShapeStyle(content.quaternary)
			case 4...:
				AnyShapeStyle(content.quinary)
			default:
				AnyShapeStyle(content)
			}
		} else {
			switch level {
			case 1:
				AnyShapeStyle(content.opacity(0.5))
			case 2:
				AnyShapeStyle(content.opacity(0.25))
			case 3:
				AnyShapeStyle(content.opacity(0.2))
			case 4...:
				AnyShapeStyle(content.opacity(0.175))
			default:
				AnyShapeStyle(content)
			}
		}
	}
}
