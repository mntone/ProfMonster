import MonsterAnalyzerCore
import SwiftUI

struct MonsterList: View {
	@ObservedObject
	private var viewModel: GameViewModel

	@Binding
	private var selectedViewModel: MonsterViewModel?

	init(_ viewModel: GameViewModel,
		 selected selectedViewModel: Binding<MonsterViewModel?>) {
		self.viewModel = viewModel
		self._selectedViewModel = selectedViewModel
	}

	var body: some View {
		List(viewModel.monsters, id: \.self, selection: $selectedViewModel) { item in
			MonsterListItem(item)
		}
		.searchable(text: $viewModel.searchText, prompt: Text("game.search[long]"))
		.onChangeBackport(of: viewModel, initial: true) { _, viewModel in
			viewModel.loadIfNeeded()
		}
#if os(macOS)
		.alternatingRowBackgroundsBackport(enable: true)
#else
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name ?? viewModel.id)
	}
}

#Preview {
	MonsterList(GameViewModel(config: MHMockDataOffer.configTitle),
				selected: .constant(nil))
}
