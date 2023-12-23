import SwiftUI

struct DividedHStack<Content: View>: View {
	struct _Proxy: _VariadicView_MultiViewRoot {
		let alignment: VerticalAlignment
		let spacing: CGFloat?

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let first = children.first {
				HStack(alignment: alignment, spacing: spacing) {
					first
					ForEach(children.dropFirst()) { child in
						child.background(alignment: .leading) {
							Divider()
						}
					}
				}
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(alignment: VerticalAlignment = .center,
		 spacing: CGFloat? = nil,
		 @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(alignment: alignment, spacing: spacing), content: content)
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
