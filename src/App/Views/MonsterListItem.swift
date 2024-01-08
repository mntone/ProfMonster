import SwiftUI

struct MonsterListItem: View {
#if !os(macOS)
	@Environment(\.settings)
	private var settings
#endif

	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		HStack(spacing: 0) {
			Text(viewModel.name)

			if viewModel.isFavorited {
				Spacer()
				Image(systemName: "star.fill")
					.foregroundStyle(.yellow)
					.accessibilityLabel("Favorited")
					.transition(.opacity)
			}
		}
		.animation(.easeInOut(duration: 0.1), value: viewModel.isFavorited)
#if !os(watchOS)
		.contextMenu {
			FavoriteContextMenuButton(favorite: $viewModel.isFavorited)
		}
#endif
#if !os(macOS)
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			switch settings?.trailingSwipeAction {
			case Optional.none, .some(.none):
				EmptyView()
			case .favorite:
				FavoriteSwipeButton(favorite: $viewModel.isFavorited)
			}
		}
#endif
	}
}

#if DEBUG || targetEnvironment(simulator)
#Preview {
	let viewModel = GameItemViewModel(id: "mockgame:gulu_qoo")!
	return List {
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
	}
}
#endif
