import SwiftUI

struct DividedHStack<Content: View, Divider: View>: View {
	struct _Proxy: _VariadicView_MultiViewRoot {
		let alignment: VerticalAlignment
		let spacing: CGFloat?
		let divider: Divider

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let first = children.first {
				HStack(alignment: alignment, spacing: spacing) {
					first
					ForEach(children.dropFirst()) { child in
						child.background(alignment: .leading) {
							divider
						}
					}
				}
				.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(alignment: VerticalAlignment = .center,
		 spacing: CGFloat? = nil,
		 @ViewBuilder content: () -> Content,
		 @ViewBuilder divider: () -> Divider) {
		_tree = _VariadicView.Tree(_Proxy(alignment: alignment, spacing: spacing, divider: divider()), content: content)
	}

	init(alignment: VerticalAlignment = .center,
		 spacing: CGFloat? = nil,
		 @ViewBuilder content: () -> Content) where Divider == SwiftUI.Divider {
		_tree = _VariadicView.Tree(_Proxy(alignment: alignment, spacing: spacing, divider: SwiftUI.Divider()), content: content)
	}

	var body: some View {
		_tree
	}
}

#Preview {
	DividedHStack(alignment: .center) {
		ForEach(0...10, id: \.self) { item in
			Text(String(item))
				.padding(.horizontal, 8)
		}
	}
	.previewLayout(.sizeThatFits)
}
