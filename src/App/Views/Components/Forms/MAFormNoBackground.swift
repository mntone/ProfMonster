import SwiftUI

@available(watchOS, unavailable)
struct MAFormNoBackground<Content: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
#if os(iOS)
		let rowInsets: EdgeInsets?
#else
		let rowInsets: EdgeInsets
#endif
		let rowSpacing: CGFloat
		let sectionSpacing: CGFloat

		@Environment(\.defaultMinListRowHeight)
		private var defaultMinListRowHeight

		@Environment(\.horizontalLayoutMargin)
		private var horizontalLayoutMargin

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let last = children.last {
#if os(iOS)
				let overrideRowInsets = rowInsets ?? EdgeInsets(vertical: MAFormMetrics.verticalRowInset,
																horizontal: horizontalLayoutMargin)
#else
				let overrideRowInsets = rowInsets
#endif
				ForEach(children.dropLast()) { child in
					child
						.padding(overrideRowInsets)
						.frame(minHeight: defaultMinListRowHeight)
						.padding(.bottom, rowSpacing)
				}

				last
					.padding(overrideRowInsets)
					.frame(minHeight: defaultMinListRowHeight)
					.padding(.bottom, sectionSpacing)
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(rowInsets: EdgeInsets? = nil,
		 rowSpacing: CGFloat? = nil,
		 sectionSpacing: CGFloat? = nil,
		 @ViewBuilder content: () -> Content) {
#if os(iOS)
		_tree = _VariadicView.Tree(
			_Proxy(rowInsets: rowInsets,
				   rowSpacing: rowSpacing ?? MAFormMetrics.rowSpacing,
				   sectionSpacing: sectionSpacing ?? MAFormMetrics.sectionSpacing),
			content: content)
#else
		_tree = _VariadicView.Tree(
			_Proxy(rowInsets: rowInsets ?? MAFormMetrics.rowInsets,
				   rowSpacing: rowSpacing ?? MAFormMetrics.rowSpacing,
				   sectionSpacing: sectionSpacing ?? MAFormMetrics.sectionSpacing),
			content: content)
#endif
	}

	var body: some View {
		_tree
	}
}
