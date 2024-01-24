import SwiftUI

struct VSpacer<Content: View>: View {
	struct _Proxy: _VariadicView_MultiViewRoot {
		let spacing: CGFloat

		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let last = children.last {
				ForEach(children.dropLast()) { child in
					child.padding(EdgeInsets(top: 0.0,
											 leading: 0.0,
											 bottom: spacing,
											 trailing: 0.0))
				}
				last
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(spacing: CGFloat, @ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(spacing: spacing), content: content)
	}

	var body: some View {
		_tree
	}
}
