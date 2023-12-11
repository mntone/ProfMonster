import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
struct GameView: View {
	@ObservedObject
	private var viewModel: GameViewModel

	init(_ viewModel: GameViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List(viewModel.monsters) { item in
			NavigationLink(value: MARoute.monster(gameId: item.gameId, monsterId: item.id)) {
				MonsterListItem(item)
			}
		}
#if os(iOS)
		.listStyle(.plain)
#endif
		.navigationTitle(viewModel.name ?? viewModel.id)
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use GameView instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use GameView instead")
struct GameViewBackport: View {
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
		List(viewModel.monsters) { item in
			NavigationLink(tag: item, selection: $selectedViewModel) {
				MonsterView(item)
			} label: {
				MonsterListItem(item)
			}
		}
#if os(iOS)
		.listStyle(.plain)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name ?? viewModel.id)
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

#Preview {
	if #available(iOS 16.0, watchOS 9.0, *) {
		GameView(GameViewModel(config: MHMockDataOffer.configTitle))
	} else {
		GameViewBackport(GameViewModel(config: MHMockDataOffer.configTitle), selected: .constant(nil))
	}
}

#endif
