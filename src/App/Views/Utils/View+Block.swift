import SwiftUI

extension View {
	func block<Content>(@ViewBuilder _ transform: (Self) -> Content) -> Content {
		transform(self)
	}
}
