import SwiftUI

struct ProgressIndicatorView: View {
	var body: some View {
		VStack(spacing: spacing) {
			ProgressView()
			Text("Loading…")
#if os(iOS)
				.font(.callout)
#endif
		}
	}

	private var spacing: CGFloat {
		@inline(__always)
		get {
#if os(watchOS)
			6.0
#else
			10.0
#endif
		}
	}
}

#Preview {
	ProgressIndicatorView()
}
