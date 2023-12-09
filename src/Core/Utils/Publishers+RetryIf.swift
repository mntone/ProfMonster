import Combine
import Foundation

public extension Publishers {
	struct RetryIf<Upstream>: Publisher where Upstream: Publisher {
		public typealias Output = Upstream.Output
		public typealias Failure = Upstream.Failure

		public let upstream: Upstream
		public let times: Int
		public let condition: (Upstream.Failure) -> Bool

		public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
			guard times > 0 else {
				return upstream.receive(subscriber: subscriber)
			}

			upstream.catch { (error: Upstream.Failure) -> AnyPublisher<Output, Failure> in
				if condition(error)  {
					return RetryIf(upstream: upstream, times: times - 1, condition: condition).eraseToAnyPublisher()
				} else {
					return Fail(error: error).eraseToAnyPublisher()
				}
			}.receive(subscriber: subscriber)
		}
	}
}

public extension Publisher {
	func retry(times: Int, if condition: @escaping (Failure) -> Bool) -> Publishers.RetryIf<Self> {
		Publishers.RetryIf(upstream: self, times: times, condition: condition)
	}
}
