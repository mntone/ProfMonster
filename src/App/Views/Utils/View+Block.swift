import SwiftUI

extension View {
	func block<Content: View>(@ViewBuilder _ transform: (Self) -> Content) -> some View {
		transform(self)
	}
}
