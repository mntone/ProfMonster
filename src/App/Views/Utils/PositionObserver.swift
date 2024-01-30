import SwiftUI

struct XObserver: View {
	let perform: (CGFloat) -> Void

	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					perform(proxy.frame(in: .global).origin.x)
				}
				.onChange(of: proxy.frame(in: .global).origin.x, perform: perform)
		}
		.frame(width: 0.0, height: 0.0)
	}
}

struct YObserver: View {
	let perform: (CGFloat) -> Void

	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					perform(proxy.frame(in: .global).origin.y)
				}
				.onChange(of: proxy.frame(in: .global).origin.y, perform: perform)
		}
		.frame(width: 0.0, height: 0.0)
	}
}
