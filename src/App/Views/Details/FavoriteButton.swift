import SwiftUI

struct FavoriteButton: View {
	@Binding
	private(set) var favorite: Bool

	var body: some View {
		let text: LocalizedStringKey, image: String
		if favorite {
			text = "Remove Favorite"
			image = "star.fill"
		} else {
			text = "Add to Favorites"
			image = "star"
		}

		return Button(text, systemImage: image) {
			favorite.toggle()
		}
		.animation(.easeInOut, value: favorite)
#if os(watchOS)
		.foregroundStyle(.yellow)
#else
		.help(text)
#if os(iOS)
		.tint(.yellow)
#endif
		.keyboardShortcut("F", modifiers: .command)
#endif
	}
}
