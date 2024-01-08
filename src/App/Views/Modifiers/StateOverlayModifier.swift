import SwiftUI

struct StateOverlayModifier: ViewModifier {
	let state: RequestState

	func body(content: Content) -> some View {
		content.overlay {
			switch state {
			case .loading:
				ProgressView()
			case let .failure(_, error):
				Text(error.label)
					.scenePadding()
			default:
				EmptyView()
			}
		}
	}
}

extension View {
	@inline(__always)
	@ViewBuilder
	func stateOverlay(_ state: RequestState) -> ModifiedContent<Self, StateOverlayModifier> {
		modifier(StateOverlayModifier(state: state))
	}
}
