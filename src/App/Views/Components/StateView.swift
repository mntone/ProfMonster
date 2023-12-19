import MonsterAnalyzerCore
import SwiftUI

struct StateView<Content: View, Data>: View {
	private let state: StarSwingsState<Data>
	private let content: (Data) -> Content
	private let background: Color?

	init(state: StarSwingsState<Data>,
		 background: Color? = nil,
		 @ViewBuilder content: @escaping (Data) -> Content) {
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
			case let .complete(data):
				content(data)
			case .failure:
				Text(verbatim: "Error")
			}
		}
	}
}
