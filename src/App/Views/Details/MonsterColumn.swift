import SwiftUI

@available(watchOS, unavailable)
struct MonsterColumn: View {
	@SceneStorage("m")
	private var selection: String?

	@StateObject
	private var viewModel = MonsterViewModel()

	var body: some View {
		MonsterView(viewModel: viewModel)
			.task(id: selection) {
				if let id = selection?.split(separator: ";", maxSplits: 1).last.map(String.init) {
					viewModel.set(id: id)
				} else {
					viewModel.set()
				}
			}
	}
}
