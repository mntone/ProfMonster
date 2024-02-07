import SwiftUI

@available(watchOS, unavailable)
struct MAFormSeparatedRoundedBackground<Content: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
		let metrics: MAFormLayoutMetrics

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let last = children.last {
				let backgroundShape: RoundedRectangle = .rect(cornerRadius: MAFormMetrics.cornerRadius)
#if os(macOS)
				let background = backgroundShape
					.strokeBorder(.formSectionSeparator, antialiased: false)
					.background(.formItemBackground)
#endif
				let rowInsets = EdgeInsets(top: 0.0,
										   leading: metrics.layoutMargin,
										   bottom: 0.0,
										   trailing: metrics.layoutMargin)
				ForEach(children.dropLast()) { child in
					child
						.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
						.padding(rowInsets)
#if os(macOS)
						.background(background)
#else
						.background(.formItemBackground)
#endif
						.containerShape(backgroundShape)
						.padding(.bottom, metrics.rowSpacing ?? 5.0)
				}

				last
					.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
					.padding(rowInsets)
#if os(macOS)
					.background(background)
#else
					.background(.formItemBackground)
#endif
					.containerShape(backgroundShape)
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(_ metrics: MAFormLayoutMetrics, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(metrics: metrics), content: content)
	}

	var body: some View {
		_tree.environment(\._inOwnerdrawBackgroundContext, true)
	}
}
