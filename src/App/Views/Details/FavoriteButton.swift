import SwiftUI

struct FavoriteButton: View {
	let viewModel: MonsterViewModel
	
	var body: some View {
		Button("Add to Favorites", systemImage: "star") {
			viewModel.isFavorited = true
		}
#if os(watchOS)
		.foregroundStyle(.yellow)
#else
		.help("Add to Favorites")
#if os(iOS)
		.tint(.yellow)
#endif
#endif
	}
}
