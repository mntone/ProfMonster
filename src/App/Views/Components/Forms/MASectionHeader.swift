import SwiftUI

struct MASectionHeader: View {
#if os(macOS)
	static let topSpacing: CGFloat = 20.0
#else
	static let topSpacing: CGFloat = 8.0
#endif

	let header: Text

#if os(iOS)
	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin
#endif

	var body: some View {
		header
			.font(.title3.bold())
#if os(iOS)
			.padding(EdgeInsets(top: Self.topSpacing,
								leading: horizontalLayoutMargin,
								bottom: 10.0,
								trailing: horizontalLayoutMargin))
#elseif os(macOS)
			.padding(EdgeInsets(top: Self.topSpacing,
								leading: MAFormMetrics.horizontalRowInset,
								bottom: 10.0,
								trailing: MAFormMetrics.horizontalRowInset))
#endif
	}
}
