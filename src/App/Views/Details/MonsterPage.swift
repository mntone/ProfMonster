import SwiftUI

struct MonsterPage: View {
	let id: CoordinatorUtil.MonsterIDType

	@State
	private var isEntrance: Bool = true

	@StateObject
	private var viewModel = MonsterViewModel()

	var body: some View {
		MonsterView(isEntrance: isEntrance, viewModel: viewModel)
			.task {
				viewModel.set(id: id)
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
					isEntrance = false
				}
			}
	}
}
