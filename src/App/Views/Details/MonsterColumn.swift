import SwiftUI

struct MonsterColumn: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@StateObject
	private var viewModel = MonsterViewModel()

	var body: some View {
		MonsterView(viewModel: viewModel)
			.task {
				let id = coord.selectedMonsterID?.split(separator: ";", maxSplits: 1).last.map(String.init)
				viewModel.set(id: id)
			}
			.onChange(of: coord.selectedMonsterID) { newValue in
				let id = newValue?.split(separator: ";", maxSplits: 1).last.map(String.init)
				viewModel.set(id: id)
			}
	}
}
