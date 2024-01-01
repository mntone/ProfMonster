import SwiftUI

// iOS 16, maybe buggy:
// https://qiita.com/SNQ-2001/items/b60d55c7436efff24a65
// TODO: Confirm actual implemenets on macOS 14
extension Backport where Content: ShapeStyle {
	var secondary: any ShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			content.secondary
		} else {
			content.opacity(0.5)
		}
	}

	var tertiary: any ShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			content.tertiary
		} else {
			content.opacity(0.25)
		}
	}

	var quaternary: any ShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			content.quaternary
		} else {
			content.opacity(0.2)
		}
	}

	var quinary: any ShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			content.quinary
		} else {
			content.opacity(0.175)
		}
	}

	func hierarchical(_ level: Int) -> any ShapeStyle {
		if #available(iOS 17.0, macOS 14.0, watchOS 10.0, *) {
			switch level {
			case 1:
				content.secondary
			case 2:
				content.tertiary
			case 3:
				content.quaternary
			case 4...:
				content.quinary
			default:
				content
			}
		} else {
			switch level {
			case 1:
				content.opacity(0.5)
			case 2:
				content.opacity(0.25)
			case 3:
				content.opacity(0.2)
			case 4...:
				content.opacity(0.175)
			default:
				content
			}
		}
	}
}
