import SwiftUI

@available(watchOS, unavailable)
struct MonsterColumn: View {
	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selection: CoordinatorUtil.MonsterIDType?

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
