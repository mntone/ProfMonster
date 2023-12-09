import MonsterAnalyzerCore
import SwiftUI

struct MonsterItemView: View {
	@ObservedObject
	private var viewModel: MonsterViewModel

	init(_ viewModel: MonsterViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		Text(verbatim: viewModel.name ?? viewModel.id)
			.redacted(reason: viewModel.name == nil ? .placeholder : [])
	}
}

struct GameView: View {
	@ObservedObject
	private var viewModel: GameViewModel

	init(_ viewModel: GameViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List {
			if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
				ForEach(viewModel.monsters) { item in
					NavigationLink(value: MARoute.monster(gameId: item.gameId, monsterId: item.id)) {
						MonsterItemView(item)
					}
				}
			} else {
				ForEach(viewModel.monsters) { item in
					NavigationLink {
						MonsterView(item)
					} label: {
						MonsterItemView(item)
					}
				}
			}
		}
#if os(macOS)
		.listStyle(.sidebar)
#elseif os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name ?? viewModel.id)
	}
}

#Preview {
	GameView(GameViewModel(config: MHMockDataOffer.configTitle))
}
