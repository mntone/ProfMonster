import SwiftUI

struct ScrollViewOffsetYDetector<ResultType: Hashable>: View {
	let coordinateSpace: String

	@Binding
	private(set) var result: ResultType

	let transform: (CGFloat) -> ResultType

	var body: some View {
		GeometryReader { proxy -> Never? in
			DispatchQueue.main.async {
				let offset = proxy.frame(in: .named(coordinateSpace)).origin.y
				let transformedValue = transform(offset)
				if result != transformedValue {
					result = transformedValue
				}
			}
			return Never?.none
		}
	}
}
