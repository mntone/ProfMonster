import SwiftUI

@available(watchOS, unavailable)
struct MAFormNoBackground<Content: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
		let metrics: MAFormLayoutMetrics

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let last = children.last {
				ForEach(children.dropLast()) { child in
					child
						.frame(minHeight: metrics.minRowHeight)
						.padding(.bottom, metrics.rowSpacing ?? 0.0)
				}

				last
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(_ metrics: MAFormLayoutMetrics, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(metrics: metrics), content: content)
	}

	var body: some View {
		_tree
	}
}
