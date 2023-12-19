import Combine

extension Publisher where Self.Failure == Never {
	func get(in set: inout Set<AnyCancellable>) async -> Output {
		await withCheckedContinuation { continuation in
			first()
				.sink { value in
					continuation.resume(returning: value)
				}
				.store(in: &set)
		}
	}
}
