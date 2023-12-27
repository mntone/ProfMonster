import MonsterAnalyzerCore
import SwiftUI

struct MonsterListItem: View {
	let viewModel: GameItemViewModel

	var body: some View {
		Text(verbatim: viewModel.name)
	}
}

#if DEBUG || targetEnvironment(simulator)
#Preview {
	AsyncPreviewSupport { viewModel in
		List {
			MonsterListItem(viewModel: viewModel)
			MonsterListItem(viewModel: viewModel)
			MonsterListItem(viewModel: viewModel)
			MonsterListItem(viewModel: viewModel)
		}
	} task: {
		let viewModel = await GameItemViewModel(id: "gulu_qoo", gameID: "mockgame")
		return viewModel
	}
}
#endif
