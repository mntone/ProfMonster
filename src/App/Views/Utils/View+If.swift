import SwiftUI

extension View {
	@ViewBuilder
	func `if`<Content: View>(_ condition: Bool,
							 if transform: (Self) -> Content) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}

	@ViewBuilder
	func `if`<TrueContent: View,
			  FalseContent: View>(_ condition: Bool,
								  if ifTransform: (Self) -> TrueContent,
								  else elseTransform: (Self) -> FalseContent) -> some View {
		if condition {
			ifTransform(self)
		} else {
			elseTransform(self)
		}
	}
}
