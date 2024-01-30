import SwiftUI

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct TopSeparatorRemover<Content: View>: View {
	struct _Proxy: _VariadicView_MultiViewRoot {
		@ViewBuilder
		func body(children: _VariadicView.Children) -> some View {
			if let first = children.first {
				if #available(iOS 16.0, *) {
					first.listRowSeparator(.hidden, edges: .top)
				} else {
					first
				}

				ForEach(children.dropFirst()) { child in
					child
				}
			}
		}
	}

	private let _tree: _VariadicView.Tree<_Proxy, Content>

	init(@ViewBuilder content: () -> Content) {
		_tree = _VariadicView.Tree(_Proxy(), content: content)
	}

	var body: some View {
		_tree
	}
}
