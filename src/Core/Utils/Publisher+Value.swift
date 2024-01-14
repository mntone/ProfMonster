import Combine

extension Publisher {
	var value: Output {
		get async throws {
			try await withCheckedThrowingContinuation { continuation in
				var cancellable: AnyCancellable?
				var finishedWithoutValue = true
				cancellable = first()
					.sink { result in
						switch result {
						case .finished:
							if finishedWithoutValue {
								continuation.resume(throwing: StarSwingsError.cancelled)
							}
						case let .failure(error):
							continuation.resume(throwing: error)
						}
						cancellable?.cancel()
					} receiveValue: { value in
						finishedWithoutValue = false
						continuation.resume(with: .success(value))
					}
			}
		}
	}
}

extension Publisher where Failure == Never {
	var value: Output {
		get async throws {
			try await withCheckedThrowingContinuation { continuation in
				var cancellable: AnyCancellable?
				var finishedWithoutValue = true
				cancellable = first()
					.sink { result in
						if finishedWithoutValue {
							continuation.resume(throwing: StarSwingsError.cancelled)
						}
						cancellable?.cancel()
					} receiveValue: { value in
						finishedWithoutValue = false
						continuation.resume(with: .success(value))
					}
			}
		}
	}
}
