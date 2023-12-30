import Combine

extension Collection where Element: Publisher {
	public var combineLatest: Publishers.CombineLatestCollection<Self> {
		Publishers.CombineLatestCollection(upstreams: self)
	}
}

extension Publishers {
	public struct CombineLatestCollection<Upstreams: Collection>: Publisher where Upstreams.Element: Combine.Publisher {
		public typealias Output = [Upstreams.Element.Output]
		public typealias Failure = Upstreams.Element.Failure

		private let upstreams: Upstreams

		init(upstreams: Upstreams) {
			self.upstreams = upstreams
		}

		public func receive<Downstream: Subscriber>(subscriber downstream: Downstream)
		where Downstream.Input == Output, Downstream.Failure == Failure
		{
			let inner = Inner<Downstream>(downstream: downstream, upstreamCount: upstreams.count)
			upstreams.enumerated().forEach { index, upstream in
				upstream.map { (index, $0) }.subscribe(inner)
			}
		}
	}
}

extension Publishers.CombineLatestCollection {
	private final class Inner<Downstream: Subscriber>: Combine.Subscriber where Downstream.Input == [Upstreams.Element.Output] {
		typealias Input = (index: Int, value: Upstreams.Element.Output)
		typealias Failure = Downstream.Failure

		private let downstream: Downstream
		private let upstreamCount: Int
		private let subscriptions: MultipleSubscription

		private var storage: Storage
		private var isCompleted: Bool

		fileprivate init(downstream: Downstream, upstreamCount: Int) {
			self.downstream = downstream
			self.subscriptions = MultipleSubscription(capacity: upstreamCount)
			self.upstreamCount = upstreamCount
			self.storage = .prebuild([Upstreams.Element.Output?](repeating: nil, count: upstreamCount))
			self.isCompleted = false
		}

		func receive(subscription: Subscription) {
			subscriptions.subscriptions.append(subscription)
			guard subscriptions.subscriptions.count == upstreamCount else { return }
			downstream.receive(subscription: subscriptions)
		}

		func receive(_ input: Input) -> Subscribers.Demand {
			switch storage {
			case var .complete(data):
				data[input.index] = input.value
				storage = .complete(data)
				return downstream.receive(data)
			case var .prebuild(data):
				data[input.index] = input.value
				if data.allSatisfy({ $0 != nil }) {
					storage = .complete(data as! [Upstreams.Element.Output])
				} else {
					storage = .prebuild(data)
				}
			}
			return .none
		}

		func receive(completion: Subscribers.Completion<Downstream.Failure>) {
			switch completion {
			case .finished:
				guard !isCompleted else { return }
				isCompleted = true
			default:
				break
			}
			downstream.receive(completion: completion)
		}

		private enum Storage {
			case prebuild([Upstreams.Element.Output?])
			case complete([Upstreams.Element.Output])
		}
	}

	private final class MultipleSubscription: Subscription {
		fileprivate var subscriptions: [Subscription] = []

		fileprivate init(capacity: Int) {
			subscriptions.reserveCapacity(capacity)
		}

		func request(_ demand: Subscribers.Demand) {
			for subscription in subscriptions {
				subscription.request(demand)
			}
		}

		func cancel() {
			for subscription in subscriptions {
				subscription.cancel()
			}
		}
	}
}
