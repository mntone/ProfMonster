import SwiftUI

@available(watchOS, unavailable)
struct MAFormRoundedBackground<Content: View, Footer: View>: View {
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
				let separator = MAHDivider().padding(.horizontal, metrics.layoutMargin)
#else
				let separator = MAHDivider().padding(.leading, metrics.layoutMargin)
#endif
				let rowInsets = EdgeInsets(top: 0.0,
										   leading: metrics.layoutMargin,
										   bottom: metrics.rowSpacing ?? 0.0,
										   trailing: metrics.layoutMargin)
				VStack(alignment: .leading, spacing: 0) {
					ForEach(children.dropLast()) { child in
						child
							.frame(minHeight: metrics.minRowHeight)
							.padding(rowInsets)
							.overlay(separator, alignment: .bottom)
						//separator // SwiftUI.ListStyle.insetGrouped default style, not Apple Design Resources (Comment out overlay)
					}

					last
						.frame(minHeight: metrics.minRowHeight)
						.padding(.horizontal, metrics.layoutMargin)
				}
				.frame(maxWidth: .infinity, alignment: .leading)
#if os(macOS)
				.background(background)
#else
				.background(.formItemBackground, in: backgroundShape)
#endif

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
