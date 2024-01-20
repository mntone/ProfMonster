import SwiftUI

@available(watchOS, unavailable)
struct MAFormSeparatedRoundedBackground<Content: View, Footer: View>: View {
	private struct _Proxy: _VariadicView_MultiViewRoot {
		let footer: Footer?
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
				ForEach(children.dropLast()) { child in
					child
						.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
						.padding(.horizontal, metrics.layoutMargin)
#if os(macOS)
						.background(background)
#else
						.background(.formItemBackground, in: backgroundShape)
#endif
						.containerShape(backgroundShape)
						.padding(.bottom, metrics.rowSpacing ?? 5.0)
				}

				last
					.frame(maxWidth: .infinity, minHeight: metrics.minRowHeight, alignment: .leading)
					.padding(.horizontal, metrics.layoutMargin)
#if os(macOS)
					.background(background)
#else
					.background(.formItemBackground, in: backgroundShape)
#endif
					.containerShape(backgroundShape)

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
		 footer: Footer?, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(footer: footer, metrics: metrics), content: content)
	}

	var body: some View {
		_tree
	}
}

