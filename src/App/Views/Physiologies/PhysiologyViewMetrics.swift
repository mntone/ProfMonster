import SwiftUI

enum PhysiologyViewMetrics {
#if os(macOS)
	static let textStyle: Font.TextStyle = .body
	static let defaultFontSize: CGFloat = 13
	static let headerBaseWidth: CGFloat = 100
	static let itemBaseWidth: CGFloat = 28
	static let maxWidth: CGFloat = 600

	static let margin: EdgeInsets = EdgeInsets(top: 8, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
	static let spacing: CGFloat = 4
	static let cornerRadius: CGFloat = 6
#elseif os(watchOS)
	static let textStyle: Font.TextStyle = .caption2
	static let defaultFontSize: CGFloat = 14
	static let headerBaseWidth: CGFloat = 60
	static let itemBaseWidth: CGFloat = 20

	static let margin: EdgeInsets = EdgeInsets(top: 6, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
	static let spacing: CGFloat = 4
	static let cornerRadius: CGFloat = 8
#else
	static let textStyle: Font.TextStyle = .subheadline
	static let defaultFontSize: CGFloat = 15
	// Japanese: 60.0 (4 chars width), Chinese: 66.0 (4 chars width + extra), Korean: 75.0 (5 chars width), the others: 90.0
	static var headerBaseWidth: CGFloat = {
		CGFloat(CGFloat.NativeType(String(localized: "PhysiologyViewMetrics.headerBaseWidth")) ?? 100.0)
	}()
	static let itemBaseWidth: CGFloat = 28
	static let maxWidth: CGFloat = 480
	static let baseMaxContentWidth: CGFloat = 400

	static let margin: EdgeInsets = EdgeInsets(top: 8, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
	static let spacing: CGFloat = 4
	static let cornerRadius: CGFloat = 6
#endif
}
