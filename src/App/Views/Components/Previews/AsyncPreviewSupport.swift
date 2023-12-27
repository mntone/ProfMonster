import SwiftUI

#if DEBUG || targetEnvironment(simulator)

struct AsyncPreviewSupport<Content: View, Data>: View {
	private let content: (Data) -> Content
	private let task: () async -> Data

	@State
	private var data: Data?

	init(@ViewBuilder content: @escaping (Data) -> Content,
		 task: @escaping () async -> Data) {
		self.content = content
		self.task = task
	}

	var body: some View {
		ZStack {
			if let data {
				content(data)
			} else {
				ProgressView()
			}
		}
		.task {
			data = await task()
		}
	}
}

#endif
