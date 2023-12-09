import MonsterAnalyzerCore
import SwiftUI

struct HomeItemView: View {
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

struct HomeView: View {
	@State
	private var isSettingsOpened: Bool = false

	@ObservedObject
	private var viewModel: HomeViewModel

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List {
			if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
				ForEach(viewModel.games) { item in
					NavigationLink(value: MARoute.game(gameId: item.id)) {
						HomeItemView(item)
					}
				}
			} else {
				ForEach(viewModel.games) { item in
					NavigationLink {
						GameView(item)
					} label: {
						HomeItemView(item)
					}
				}
			}
		}
		.sheet(isPresented: $isSettingsOpened) {
			SettingsContainerView()
		}
		.leadingToolbarItemBackport {
			Button("settings.action", systemImage: "gearshape.fill") {
				isSettingsOpened = true
			}
		}
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

#Preview {
	HomeView(HomeViewModel(games: [
		GameViewModel(config: MHMockDataOffer.configTitle)
	]))
}
