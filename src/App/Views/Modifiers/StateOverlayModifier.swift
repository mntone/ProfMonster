import SwiftUI

#if !os(watchOS)

@available(watchOS, unavailable)
private struct DelayedProgressIndicatorView: View {
	@State
	private var isProgressShown: Bool = false

	var body: some View {
		Color.clear
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.task {
				try? await Task.sleep(nanoseconds: 666_666_666 /* 2/3 secs */)
				isProgressShown = true
			}

		if isProgressShown {
			Color(white: 0, opacity: 0.2)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			VStack(spacing: 20) {
				ProgressView()
				Text("Loading…")
			}
			.offset(y: 10)
			.frame(width: 120, height: 120)
			.background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
		}
	}
}

#endif

struct StateOverlayModifier: ViewModifier {
	let state: RequestState
	let refreshAction: () -> Void

	fileprivate init(state: RequestState,
					 refreshAction: @escaping () -> Void) {
		self.state = state
		self.refreshAction = refreshAction
	}

	func body(content: Content) -> some View {
		content.overlay {
			switch state {
			case .loading:
				Color.clear
#if os(iOS)
				if UIDevice.current.userInterfaceIdiom == .pad {
					DelayedProgressIndicatorView()
				} else {
					ProgressIndicatorView()
				}
#elseif os(macOS)
				DelayedProgressIndicatorView()
#else
				ProgressIndicatorView()
#endif
			case let .failure(reset, error):
				ErrorView(reset: reset,
						  error: error,
						  refresh: refreshAction)
			default:
				Never?.none
			}
		}
	}
}

extension View {
	@inline(__always)
	@ViewBuilder
	func stateOverlay(_ state: RequestState, refresh: @escaping () -> Void) -> some View {
		modifier(StateOverlayModifier(state: state, refreshAction: refresh))
	}
}
