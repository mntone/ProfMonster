import SwiftUI

enum MAFormMetrics {
#if os(iOS)
	static let cornerRadius: CGFloat = 10.0
	static let verticalRowInset: CGFloat = 10.0
	static let rowSpacing: CGFloat = 5.0
	static let sectionSpacing: CGFloat = 20.0
#endif
#if os(macOS)
	static let cornerRadius: CGFloat = 6.0
	static let verticalRowInset: CGFloat = 10.0
	static let horizontalRowInset: CGFloat = 10.0
	static let rowInsets: EdgeInsets = EdgeInsets(vertical: verticalRowInset,
												  horizontal: horizontalRowInset)
	static let rowSpacing: CGFloat = 5.0
	static let sectionSpacing: CGFloat = 10.0
#endif
#if os(watchOS)
	static let verticalRowInset: CGFloat = 9.0
#endif
}
