import SwiftUI

struct MonsterPage: View {
	let id: CoordinatorUtil.MonsterIDType

	@StateObject
	private var viewModel = MonsterViewModel()

	var body: some View {
		MonsterView(viewModel: viewModel)
			.task {
				viewModel.set(id: id)
			}
	}
}
