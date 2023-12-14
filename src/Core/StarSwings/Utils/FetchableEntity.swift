import Combine
import Foundation

public class FetchableEntity {
	let _dataSource: MHDataSource
	let _lock: Lock = LockUtil.create()

	var cancellable: AnyCancellable?

	@Published
	public var state: StarSwingsState = .ready

	init(dataSource: MHDataSource) {
		self._dataSource = dataSource
	}

	func _handle(error: Error) {
#if DEBUG
		debugPrint(error)
#endif

		state = .failure(date: Date.now, error: error)
	}
}
