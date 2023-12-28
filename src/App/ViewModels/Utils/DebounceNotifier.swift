import Combine
import Foundation

enum DebounceNotifierMode {
	case `default`
	case immideately
}

private let scheduler = DispatchQueue.global(qos: .utility)

struct DebounceNotifier<Value: Sendable> {
	private let subject = PassthroughSubject<Value, Never>()
	private let sendAction: (Value) -> Void
	private let cancellable: AnyCancellable?

	init(interval: DispatchQueue.SchedulerTimeType.Stride,
		 send: @escaping (Value) -> Void) {
		self.sendAction = send
		self.cancellable = subject
			.debounce(for: interval, scheduler: scheduler)
			.sink(receiveValue: send)
	}

	@inline(__always)
	func send(_ value: Value, mode: DebounceNotifierMode = .default) {
		if mode == .immideately {
			sendAction(value)
		} else {
			subject.send(value)
		}
	}
}
