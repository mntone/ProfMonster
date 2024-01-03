import SwiftUI

struct FavoriteButton<ViewModel: FavoriteViewModel>: View {
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
#if os(watchOS)
			viewModel.isFavorited.toggle()
#else
			withAnimation {
				viewModel.isFavorited.toggle()
			}
#endif
		}
#if os(watchOS)
		.foregroundStyle(.yellow)
#else
		.help(text)
#if os(iOS)
		.tint(.yellow)
#endif
#endif
	}
}
