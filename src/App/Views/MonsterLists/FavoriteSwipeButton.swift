import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct FavoriteSwipeButton: View {
	@Binding
	private(set) var favorite: Bool

	var body: some View {
		let text: LocalizedStringKey, image: String
		if favorite {
			text = "Remove Favorite"
			image = "star.slash.fill"
		} else {
			text = "Add to Favorites"
			image = "star.fill"
		}

		return Button(text, systemImage: image) {
			favorite.toggle()
		}
		.tint(.yellow)
	}
}

#Preview("Favorite") {
	List {
		Text(verbatim: "Sample Context Menu")
			.swipeActions(edge: .trailing, allowsFullSwipe: false) {
				FavoriteSwipeButton(favorite: .constant(false))
			}
	}
}

#Preview("Unfavorite") {
	List {
		Text(verbatim: "Sample Context Menu")
			.swipeActions(edge: .trailing, allowsFullSwipe: false) {
				FavoriteSwipeButton(favorite: .constant(true))
			}
	}
}

#endif
