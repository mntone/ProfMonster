import SwiftUI

@available(watchOS, unavailable)
struct MAFormRoundedBackground<Content: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
#if os(iOS)
		let rowInsets: EdgeInsets?
#else
		let rowInsets: EdgeInsets
#endif
		let sectionSpacing: CGFloat

		@Environment(\.defaultMinListRowHeight)
		private var defaultMinListRowHeight

		@Environment(\.horizontalLayoutMargin)
		private var horizontalLayoutMargin

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let first = children.first {
#if os(iOS)
				let overrideRowInsets = rowInsets ?? EdgeInsets(vertical: MAFormMetrics.verticalRowInset,
																horizontal: horizontalLayoutMargin)
#else
				let overrideRowInsets = rowInsets
#endif
				let backgroundShape: RoundedRectangle = .rect(cornerRadius: MAFormMetrics.cornerRadius)
#if os(macOS)
				let background = backgroundShape
					.strokeBorder(.formSectionSeparator, antialiased: false)
					.background(.formItemBackground)
#endif
				VStack(alignment: .leading, spacing: 0) {
					first
						.padding(overrideRowInsets)
						.frame(minHeight: defaultMinListRowHeight)

					ForEach(children.dropFirst()) { child in
						MAHDivider()
#if os(macOS)
							.padding(.horizontal, horizontalLayoutMargin)
#else
							.padding(.leading, horizontalLayoutMargin)
#endif

						child
							.padding(overrideRowInsets)
							.frame(minHeight: defaultMinListRowHeight)
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
#if os(macOS)
				.background(background)
#else
				.background(.formItemBackground, in: backgroundShape)
#endif
				.padding(.bottom, sectionSpacing)
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(rowInsets: EdgeInsets? = nil,
		 sectionSpacing: CGFloat? = nil,
		@ViewBuilder content: () -> Content) {
#if os(iOS)
		_tree = _VariadicView.Tree(
			_Proxy(rowInsets: rowInsets,
				   sectionSpacing: sectionSpacing ?? MAFormMetrics.sectionSpacing),
			content: content)
#else
		_tree = _VariadicView.Tree(
			_Proxy(rowInsets: rowInsets ?? MAFormMetrics.rowInsets,
				   sectionSpacing: sectionSpacing ?? MAFormMetrics.sectionSpacing),
			content: content)
#endif
	}

	var body: some View {
		_tree
	}
}
