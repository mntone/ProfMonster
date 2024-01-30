import SwiftUI

struct MonsterPage: View {
	let id: CoordinatorUtil.MonsterIDType
	let isRoot: Bool

	@State
	private var isEntrance: Bool = true

	@StateObject
	private var viewModel = MonsterViewModel()

	init(id: CoordinatorUtil.MonsterIDType, root: Bool = false) {
		self.id = id
		self.isRoot = root
	}

	var body: some View {
		MonsterView(isEntrance: isEntrance, viewModel: viewModel)
			.task {
				viewModel.isRoot = isRoot
				viewModel.set(id: id)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
					isEntrance = false
				}
			}
	}
}
