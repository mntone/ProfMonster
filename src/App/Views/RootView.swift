import MonsterAnalyzerCore
import SwiftUI

struct RootItemView: View {
	@ObservedObject
	private var viewModel: GameViewModel

	init(_ viewModel: GameViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		Text(verbatim: viewModel.name ?? viewModel.id)
			.redacted(reason: viewModel.name == nil ? .placeholder : [])
	}
}

struct RootView: View {
#if !os(macOS)
	@Environment(\.settingsAction)
	private var settingsAction
#endif

	@ObservedObject
	private var viewModel: HomeViewModel

	@Binding
	private var selectedViewModel: GameViewModel?

	init(_ viewModel: HomeViewModel,
		 selected selectedViewModel: Binding<GameViewModel?>) {
		self.viewModel = viewModel
		self._selectedViewModel = selectedViewModel
	}

	var body: some View {
		List(viewModel.games, id: \.self, selection: $selectedViewModel) { item in
			RootItemView(item)
		}
#if !os(macOS)
		.leadingToolbarItemBackport {
			Button("root.settings", systemImage: "gearshape.fill") {
				settingsAction?.present()
			}
			.keyboardShortcut(",", modifiers: [.command])
		}
#endif
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

#Preview {
	RootView(HomeViewModel(games: [
		GameViewModel(config: MHMockDataOffer.configTitle)
	]), selected: .constant(nil))
}
