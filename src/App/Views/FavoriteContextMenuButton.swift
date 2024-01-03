import SwiftUI

@available(watchOS, unavailable)
struct FavoriteContextMenuButton<ViewModel: FavoriteViewModel>: View {
	@ObservedObject
	private(set) var viewModel: ViewModel

	var body: some View {
		let text: LocalizedStringKey, image: String
		if viewModel.isFavorited {
			text = "Remove Favorite"
			image = "star.fill"
		} else {
			text = "Add to Favorites"
			image = "star"
		}

		return Button(text, systemImage: image) {
			viewModel.isFavorited.toggle()
		}
	}
}

final class _PreviewFavoriteViewModel: FavoriteViewModel {
	var isFavorited: Bool

	init(isFavorited: Bool) {
		self.isFavorited = isFavorited
	}
}

#Preview("Favorite") {
	Text(verbatim: "Sample Context Menu")
		.padding()
		.contextMenu {
			FavoriteContextMenuButton(viewModel: _PreviewFavoriteViewModel(isFavorited: false))
		}
}

#Preview("Unfavorite") {
	Text(verbatim: "Sample Context Menu")
		.padding()
		.contextMenu {
			FavoriteContextMenuButton(viewModel: _PreviewFavoriteViewModel(isFavorited: true))
		}
}
