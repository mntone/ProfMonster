import enum MonsterAnalyzerCore.StarSwingsError
import SwiftUI

struct ErrorView: View {
	let reset: Date
	let error: StarSwingsError
	let refresh: () -> Void

	@State
	private var timer: Timer?

	@State
	private var disableRefreshButton: Bool = false

	@State
	private var enableRefresh: Bool = false

#if os(iOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 11.0 /* half of .body (22.0) */
#elseif os(watchOS)
	@ScaledMetric(relativeTo: .body)
	private var spacing: CGFloat = 8.0 /* half of .body (16.5) */
#endif

	var body: some View {
#if os(macOS)
		let spacing: CGFloat = 8.0 /* half of .body (16.0) */
#endif
		VStack(spacing: spacing) {
			Text(error.label)
				.foregroundStyle(.secondary)

			if enableRefresh {
				Button {
					disableRefreshButton = true
					refresh()
				} label: {
					Label("Refresh", systemImage: "arrow.clockwise")
						.frame(maxWidth: .infinity, minHeight: 38.0)
				}
				.buttonStyle(.bordered)
				.disabled(disableRefreshButton)
				.transition(.opacity)
			}
		}
		.scenePadding()
		.fixedSize(horizontal: false, vertical: true)
		.animation(.default, value: enableRefresh)
		.dynamicTypeSize(.large...)
		.onAppear {
			timer = Timer.scheduledTimer(withTimeInterval: reset.timeIntervalSinceNow, repeats: false) { _ in
				timer = nil
				enableRefresh = true
			}
		}
	}
}

#Preview {
	ErrorView(reset: Date.now + 3.0,
			  error: .cancelled,
			  refresh: {})
}
