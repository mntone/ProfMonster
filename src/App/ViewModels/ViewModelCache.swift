import Foundation

class ViewModelCache<ViewModel> where ViewModel: AnyObject, ViewModel: Identifiable, ViewModel.ID == String {
	private struct Bag {
		weak var value: ViewModel?
	}

	private var _cache: [String: Bag]

	init() {
		self._cache = [:]
	}

	func clear() {
		self._cache = [:]
	}

	@inlinable
	func get(id: String) -> ViewModel? {
		_cache[id]?.value
	}

	func getOrCreate(id: String, _ create: () -> ViewModel) -> ViewModel {
		if let cacheViewModel = _cache[id]?.value {
			return cacheViewModel
		} else {
			let viewModel = create()
			_cache[id] = Bag(value: viewModel)
			return viewModel
		}
	}

	@inlinable
	subscript(id: String) -> ViewModel? {
		_cache[id]?.value
	}
}
