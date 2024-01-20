import SwiftUI

enum MAFormMetrics {
#if os(iOS)
	static let cornerRadius: CGFloat = 10.0
	static let verticalRowInset: CGFloat = 11.0
#endif
#if os(macOS)
	static let cornerRadius: CGFloat = 6.0
	static let verticalRowInset: CGFloat = 10.0
	static let horizontalRowInset: CGFloat = 10.0
#endif
#if os(watchOS)
	static let verticalRowInset: CGFloat = 9.0
#endif
}

struct MAFormLayoutMetrics {
	let layoutMargin: CGFloat
	let minRowHeight: CGFloat
	let rowSpacing: CGFloat?
	let sectionSpacing: CGFloat
}
