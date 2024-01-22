import SwiftUI

@available(watchOS, unavailable)
struct MonsterColumn: View {
	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selection: CoordinatorUtil.MonsterIDType?

	@State
	private var isEntrance: Bool = true

	@StateObject
	private var viewModel = MonsterViewModel()

	var body: some View {
		MonsterView(isEntrance: isEntrance, viewModel: viewModel)
			.task(id: selection) {
				isEntrance = true
				if let id = selection?.split(separator: ";", maxSplits: 1).last.map(String.init) {
					viewModel.set(id: id)
				} else {
					viewModel.set()
				}
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.333) {
					isEntrance = false
				}
			}
	}
}
