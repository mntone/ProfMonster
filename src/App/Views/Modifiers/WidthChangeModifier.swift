import SwiftUI

struct _WidthChangeModifier: ViewModifier {
	let perform: (CGFloat) -> Void

	func body(content: Content) -> some View {
		content.background {
			GeometryReader { proxy in
				Color.clear
					.onAppear {
						perform(proxy.size.width)
					}
#if !os(watchOS)
					.onChange(of: proxy.size.width) { newValue in
						perform(newValue)
					}
#endif
			}
		}
	}
}

extension View {
	@inline(__always)
	@ViewBuilder
	func onWidthChange(perform: @escaping (CGFloat) -> Void) -> ModifiedContent<Self, _WidthChangeModifier> {
		modifier(_WidthChangeModifier(perform: perform))
	}
}
