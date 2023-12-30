import MonsterAnalyzerCore
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
			}
		}
#if !os(watchOS)
		.contextMenu {
			if viewModel.isFavorited {
				Button("Remove Favorite", systemImage: "star") {
					viewModel.isFavorited = false
				}
			} else {
				Button("Add Favorite", systemImage: "star.fill") {
					viewModel.isFavorited = true
				}
			}
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
