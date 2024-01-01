import SwiftUI

struct UnfavoriteButton: View {
	let viewModel: MonsterViewModel
	
	var body: some View {
		Button("Remove Favorite", systemImage: "star.fill") {
			viewModel.isFavorited = false
		}
#if os(watchOS)
		.foregroundStyle(.yellow)
#else
		.help("Remove Favorite")
#if os(iOS)
		.tint(.yellow)
#endif
#endif
	}
}
