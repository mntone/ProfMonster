import SwiftUI

struct ScrollViewOffsetXDetector<ResultType: Hashable>: View {
	let coordinateSpace: String

	@Binding
	private(set) var result: ResultType

	let transform: (CGFloat) -> ResultType

	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					let offsetX = proxy.frame(in: .named(coordinateSpace)).origin.x
					let transformedValue = transform(offsetX)
					if result != transformedValue {
						result = transformedValue
					}
				}
				.onChange(of: transform(proxy.frame(in: .named(coordinateSpace)).origin.x)) { transformedValue in
					if result != transformedValue {
						result = transformedValue
					}
				}
		}
	}
}

struct ScrollViewOffsetYDetector<ResultType: Hashable>: View {
	let coordinateSpace: String

	@Binding
	private(set) var result: ResultType

	let transform: (CGFloat) -> ResultType

	var body: some View {
		GeometryReader { proxy in
			Color.clear
				.onAppear {
					let offsetX = proxy.frame(in: .named(coordinateSpace)).origin.y
					let transformedValue = transform(offsetX)
					if result != transformedValue {
						result = transformedValue
					}
				}
				.onChange(of: transform(proxy.frame(in: .named(coordinateSpace)).origin.y)) { transformedValue in
					if result != transformedValue {
						result = transformedValue
					}
				}
		}
	}
}
