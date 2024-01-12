import SwiftUI

@available(watchOS, unavailable)
struct FavoriteContextMenuButton: View {
	@Binding
	private(set) var favorite: Bool

	var body: some View {
		let text: LocalizedStringKey, image: String
		if favorite {
			text = "Delete Favorite"
			image = "star.slash"
		} else {
			text = "Add to Favorites"
			image = "star"
		}

		return Button(text, systemImage: image) {
			favorite.toggle()
		}
	}
}

#Preview("Favorite") {
	Text(verbatim: "Sample Context Menu")
		.padding()
		.contextMenu {
			FavoriteContextMenuButton(favorite: .constant(false))
		}
}

#Preview("Unfavorite") {
	Text(verbatim: "Sample Context Menu")
		.padding()
		.contextMenu {
			FavoriteContextMenuButton(favorite: .constant(true))
		}
}
