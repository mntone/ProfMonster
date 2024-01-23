import SwiftUI

struct WidthObserver: View {
	let perform: (CGFloat) -> Void

	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					let width = proxy.size.width
					perform(width)
				}
				.onChange(of: proxy.size.width, perform: perform)
		}
	}
}

struct HeightObserver: View {
	let perform: (CGFloat) -> Void
	
	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					let height = proxy.size.height
					perform(height)
				}
				.onChange(of: proxy.size.height, perform: perform)
		}
	}
}
