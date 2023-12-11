import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

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

@available(iOS 16.0, watchOS 9.0, *)
struct HomeView: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private var viewModel: HomeViewModel

	init(_ viewModel: HomeViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List(viewModel.games) { item in
			NavigationLink(value: MARoute.game(gameId: item.id)) {
				HomeItemView(item)
			}
		}
		.leadingToolbarItemBackport {
			Button("settings.action", systemImage: "gearshape.fill") {
				settingsAction?.present()
			}
		}
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

@available(iOS, introduced: 13.0, deprecated: 16.0, message: "Use NavigationStackHost instead")
@available(watchOS, introduced: 7.0, deprecated: 9.0, message: "Use NavigationStackHost instead")
struct HomeViewBackport: View {
	@Environment(\.settingsAction)
	private var settingsAction

	@ObservedObject
	private var viewModel: HomeViewModel

	@Binding
	private var selectedViewModel: GameViewModel?

	@Binding
	private var nestedSelectedViewModel: MonsterViewModel?

	init(_ viewModel: HomeViewModel,
		 selected selectedViewModel: Binding<GameViewModel?>,
		 nestedSelected nestedSelectedViewModel: Binding<MonsterViewModel?>) {
		self.viewModel = viewModel
		self._selectedViewModel = selectedViewModel
		self._nestedSelectedViewModel = nestedSelectedViewModel
	}

	var body: some View {
		List(viewModel.games) { item in
			NavigationLink(tag: item, selection: $selectedViewModel) {
				GameViewBackport(item, selected: $nestedSelectedViewModel)
			} label: {
				HomeItemView(item)
			}
		}
		.leadingToolbarItemBackport {
			Button("settings.action", systemImage: "gearshape.fill") {
				settingsAction?.present()
			}
		}
		.task {
			viewModel.loadIfNeeded()
		}
	}
}

#Preview {
	if #available(iOS 16.0, watchOS 9.0, *) {
		HomeView(HomeViewModel(games: [
			GameViewModel(config: MHMockDataOffer.configTitle)
		]))
	} else {
		HomeViewBackport(HomeViewModel(games: [
			GameViewModel(config: MHMockDataOffer.configTitle)
		]), selected: .constant(nil), nestedSelected: .constant(nil))
	}
}

#endif
