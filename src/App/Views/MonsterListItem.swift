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
	let viewModel = GameItemViewModel(id: "gulu_qoo", gameID: "mockgame")
	return MonsterListItem(viewModel: viewModel)
}
#endif
