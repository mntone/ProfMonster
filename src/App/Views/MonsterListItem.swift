import SwiftUI

struct MonsterListItem: View {
	@ObservedObject
	private(set) var viewModel: GameItemViewModel

	var body: some View {
		HStack(spacing: 0) {
			Text(verbatim: viewModel.name)

			Spacer()

			if viewModel.isFavorited {
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
	}
}

#if DEBUG || targetEnvironment(simulator)
#Preview {
	let viewModel = GameItemViewModel(id: "gulu_qoo", gameID: "mockgame")!
	return List {
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
		MonsterListItem(viewModel: viewModel)
	}
}
#endif
