import Foundation
import SwiftUI

private struct _ObservableScrollViewPreferenceKey: PreferenceKey {
   static var defaultValue: CGFloat = 0

   private static var initialValue: CGFloat? = nil

   static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
   }
}

struct ObservableHorizontalScrollView<Content: View>: View {
	private let content: Content

	@Environment(\.layoutDirection)
	private var layoutDirection

	@State
	private var converter: (CGFloat) -> CGFloat = { value in value }

	@State
	private var baseOffsetX: CGFloat = 0

	@State
	private var savedOffsetX: CGFloat = 0

	@Binding
	private var offsetX: CGFloat

	init(offsetX: Binding<CGFloat>,
		 @ViewBuilder content: () -> Content) {
		self._offsetX = offsetX
		self.content = content()
	}

	var body: some View {
		ScrollView(.horizontal) {
			content.background(GeometryReader { proxy in
				Color.clear
					.preference(key: _ObservableScrollViewPreferenceKey.self,
								value: proxy.frame(in: .global).origin.x)
					.onAppear {
						if layoutDirection == .rightToLeft {
							converter = { value in -value }
						} else {
							converter = { value in value }
						}
						baseOffsetX = proxy.frame(in: .global).origin.x
					}
			})
		}.onChange(of: baseOffsetX) { newValue in
			offsetX = converter(baseOffsetX - savedOffsetX)
		}.onPreferenceChange(_ObservableScrollViewPreferenceKey.self) { offset in
			savedOffsetX = offset
			offsetX = converter(baseOffsetX - offset)
		}
	}
}
