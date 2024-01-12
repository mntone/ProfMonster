import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
private struct ProgressIndicatorView: View {
	var body: some View {
		Color.clear
		VStack(spacing: 10) {
			ProgressView()
			Text("Loading…")
		}
	}
}

#endif

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

	func body(content: Content) -> some View {
		content.overlay {
			switch state {
			case .loading:
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
			case let .failure(_, error):
				Text(error.label)
					.scenePadding()
			default:
				Never?.none
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
