import SwiftUI

@available(watchOS, unavailable)
struct MAFormNoBackground<Content: View, Footer: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
		let footer: Footer?
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

				ZStack(alignment: .topLeading) {
					Color.clear.frame(height: metrics.sectionSpacing)
					footer
				}
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(_ metrics: MAFormLayoutMetrics,
		 @ViewBuilder content: () -> Content) where Footer == Never {
		_tree = _VariadicView.Tree(_Proxy(footer: nil, metrics: metrics), content: content)
	}

	init(_ metrics: MAFormLayoutMetrics,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder footer: () -> Footer) {
		_tree = _VariadicView.Tree(_Proxy(footer: footer(), metrics: metrics), content: content)
	}

	// Use for Internal
	init(_ metrics: MAFormLayoutMetrics,
		 footer: Footer?,
		 @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(footer: footer, metrics: metrics), content: content)
	}

	var body: some View {
		_tree
	}
}
