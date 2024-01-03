import protocol Combine.ObservableObject

protocol FavoriteViewModel: ObservableObject {
	var isFavorited: Bool { get set }
}
