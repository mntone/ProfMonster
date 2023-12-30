import SwiftUI

enum PhysiologyViewMetrics {
#if os(macOS)
	static let textStyle: Font.TextStyle = .body
	static let defaultFontSize: CGFloat = 13
	static let headerBaseWidth: CGFloat = 100
	static let itemBaseWidth: CGFloat = 24
	static let maxWidth: CGFloat = 600

	static let margin: EdgeInsets = EdgeInsets(top: 8, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
	static let spacing: CGFloat = 8
#elseif os(watchOS)
	static let textStyle: Font.TextStyle = .caption2
	static let defaultFontSize: CGFloat = 14
	static let headerBaseWidth: CGFloat = 60
	static let itemBaseWidth: CGFloat = 20

	static let margin: EdgeInsets = EdgeInsets(top: 6, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 12)
	static let spacing: CGFloat = 4
#else
	static let maxScaleFactor: CGFloat = 1.9

	static let textStyle: Font.TextStyle = .subheadline
	static let defaultFontSize: CGFloat = 15
	static let headerBaseWidth: CGFloat = 88
	static let itemBaseWidth: CGFloat = 28
	static let maxWidth: CGFloat = 480

	static let margin: EdgeInsets = EdgeInsets(top: 8, leading: 4, bottom: 4, trailing: 4)
	static let padding: EdgeInsets = EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
	static let spacing: CGFloat = 4
#endif

	static let cornerRadius: CGFloat = 6
}
