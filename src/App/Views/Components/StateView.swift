import MonsterAnalyzerCore
import SwiftUI

struct StateView<Content: View>: View {
	private let state: StarSwingsState
	private let content: () -> Content
	private let background: Color?

	init(state: StarSwingsState,
		 background: Color? = nil,
		 @ViewBuilder content: @escaping () -> Content) {
		self.state = state
		self.background = background
		self.content = content
	}

	var body: some View {
		ZStack {
			if let background {
				background.ignoresSafeArea(.all)
			}

			switch state {
			case .ready:
				EmptyView()
			case .loading:
				ProgressView()
			case .complete:
				content()
			case .failure:
				Text(verbatim: "Error")
			}
		}
	}
}
