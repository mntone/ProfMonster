import Foundation

public enum RepeatBehavior {
	case immediate
	case delayed(timeInterval: TimeInterval)
	case linearDelayed(initial: TimeInterval, difference: TimeInterval, max: TimeInterval? = nil)
	case exponentialDelayed(initial: TimeInterval, multiplier: Double, max: TimeInterval? = nil)

	public func timeInterval(retry: UInt) -> TimeInterval {
		switch self {
		case .immediate:
			0.0
		case let .delayed(timeInterval):
			timeInterval
		case let .linearDelayed(initial, difference, .none):
			initial + Double(retry) * difference
		case let .linearDelayed(initial, difference, .some(max)):
			min(initial + Double(retry) * difference, max)
		case let .exponentialDelayed(initial, multiplier, .none):
			initial * pow(multiplier, Double(retry))
		case let .exponentialDelayed(initial, multiplier, .some(max)):
			min(initial * pow(multiplier, Double(retry)), max)
		}
	}
}

public struct NetworkDataSourceOptions {
	public let maxRetry: UInt
	public let repeatBehavior: RepeatBehavior

	init(maxRetry: UInt = 3,
		 repeatBehavior: RepeatBehavior = .exponentialDelayed(initial: 5.0, multiplier: 1.5, max: 10.0)) {
		self.maxRetry = maxRetry
		self.repeatBehavior = repeatBehavior
	}

	public static let `default` = NetworkDataSourceOptions()
}
