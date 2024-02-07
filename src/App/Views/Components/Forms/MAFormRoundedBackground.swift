import SwiftUI

@available(watchOS, unavailable)
struct MAFormRoundedBackground<Content: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
		let metrics: MAFormLayoutMetrics
		let hasHeader: Bool

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let last = children.last {
				let backgroundShape: RoundedRectangle = .rect(cornerRadius: MAFormMetrics.cornerRadius)
#if os(macOS)
				let background = backgroundShape
					.strokeBorder(.formSectionSeparator, antialiased: false)
					.background(.formItemBackground)
				let separator = MAHDivider().padding(.horizontal, metrics.layoutMargin)
#else
				let separator = MAHDivider().padding(.leading, metrics.layoutMargin)
#endif
				let rowInsets = EdgeInsets(top: 0.0,
										   leading: metrics.layoutMargin,
										   bottom: 0.0,
										   trailing: metrics.layoutMargin)
				LazyVStack(alignment: .leading, spacing: metrics.rowSpacing ?? 0.0) {
					let itemsExceptLast = children.dropLast()
					if hasHeader,
					   let first = itemsExceptLast.first {
						first.padding(rowInsets)

						ForEach(itemsExceptLast.dropFirst()) { child in
							child
								.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
								.padding(rowInsets)
								.overlay(separator, alignment: .bottom)
							//separator // SwiftUI.ListStyle.insetGrouped default style, not Apple Design Resources (Comment out overlay)
						}

						last
							.frame(minHeight: metrics.minRowHeight)
							.padding(rowInsets)
					} else {
						ForEach(itemsExceptLast) { child in
							child
								.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
								.padding(rowInsets)
								.overlay(separator, alignment: .bottom)
							//separator // SwiftUI.ListStyle.insetGrouped default style, not Apple Design Resources (Comment out overlay)
						}

						last
							.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
							.padding(rowInsets)
					}
				}
#if os(macOS)
				.background(background)
#else
				.background(.formItemBackground)
				.containerShape(backgroundShape)
#endif
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(_ metrics: MAFormLayoutMetrics, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(metrics: metrics, hasHeader: false), content: content)
	}

	init(_ metrics: MAFormLayoutMetrics, header hasHeader: Bool, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(metrics: metrics, hasHeader: hasHeader), content: content)
	}

	var body: some View {
		_tree.environment(\._inOwnerdrawBackgroundContext, true)
	}
}
