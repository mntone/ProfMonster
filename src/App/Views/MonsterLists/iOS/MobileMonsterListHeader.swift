import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct MobileMonsterListHeader: View {
	static let listCoordinateSpace = "list"

	let text: String
	let topOffset: CGFloat

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@Environment(\.pixelLength)
	private var pixelLength

	@ScaledMetric(relativeTo: .footnote)
	private var favoriteIconWidth: CGFloat = 13.0

	var body: some View {
		let text = Text(text)
		if #available(iOS 16.0, *) {
			let leading = horizontalLayoutMargin + favoriteIconWidth - 4.0
			text
				.padding(EdgeInsets(top: 0.0,
									leading: leading,
									bottom: 0.0,
									trailing: horizontalLayoutMargin))
				.frame(maxWidth: .infinity, minHeight: 26.0, alignment: .leading)
				.overlay(alignment: .bottom) {
					GeometryReader { proxy in
						Divider()
							.padding(EdgeInsets(top: 0.0,
												leading: leading,
												bottom: 0.0,
												trailing: 0.0))
							.opacity(proxy.frame(in: .named(Self.listCoordinateSpace)).origin.y - topOffset > 26.0 ? 1.0 : 0.0)
					}
					.frame(height: pixelLength)
				}
				.listRowInsets(.zero)
		} else {
			text.padding(EdgeInsets(top: 0.0,
									leading: favoriteIconWidth - 4.0,
									bottom: 0.0,
									trailing: 0.0))
		}
	}
}
