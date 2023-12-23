import Combine
import Foundation

public protocol UserDefaultable: Equatable {
	associatedtype Internal

	static var defaultValue: Self { get }

	init?(userDefaultable value: Internal)
	static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self
	static func set(_ newValue: Self, for key: String, in store: UserDefaults)
}

extension Bool: UserDefaultable {
	public typealias Internal = Bool

	@inline(__always)
	public static var defaultValue: Self {
		false
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.object(forKey: key) as? Bool else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension Int: UserDefaultable {
	public typealias Internal = Int

	@inline(__always)
	public static var defaultValue: Self {
		0
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.object(forKey: key) as? Int else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension Float: UserDefaultable {
	public typealias Internal = Float

	@inline(__always)
	public static var defaultValue: Self {
		0
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.object(forKey: key) as? Float else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension Double: UserDefaultable {
	public typealias Internal = Double

	@inline(__always)
	public static var defaultValue: Self {
		0
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.object(forKey: key) as? Double else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension String: UserDefaultable {
	public typealias Internal = String

	@inline(__always)
	public static var defaultValue: Self {
		""
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension Data: UserDefaultable {
	public typealias Internal = Data

	@inline(__always)
	public static var defaultValue: Self {
		Data()
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.data(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue, forKey: key)
	}
}

extension Date: UserDefaultable {
	public typealias Internal = Double

	@inline(__always)
	public static var defaultValue: Self {
		Date.distantPast
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(timeIntervalSinceReferenceDate: value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.object(forKey: key) as? Double else {
			return initialValue ?? defaultValue
		}
		return Date(timeIntervalSinceReferenceDate: value)
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.timeIntervalSinceReferenceDate, forKey: key)
	}
}

extension RawRepresentable where RawValue: UserDefaultable {
	public typealias Internal = RawValue

	@inline(__always)
	public static var defaultValue: Self {
		fatalError("Set initial value.")
	}

	@inline(__always)
	public init?(userDefaultable value: Internal) {
		self.init(rawValue: value)
	}

	@inline(__always)
	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = Self(rawValue: RawValue.get(for: key, in: store, initial: nil)) else {
			return initialValue ?? defaultValue
		}
		return value
	}

	@inline(__always)
	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		RawValue.set(newValue.rawValue, for: key, in: store)
	}
}

@propertyWrapper
public struct UserDefault<Value: UserDefaultable> {
	public let projectedValue: Self.Publisher<Value>

	public init(_ key: String,
				in store: UserDefaults? = nil,
				initial initialValue: Value? = nil) {
		self.projectedValue = Publisher(key, in: store ?? UserDefaults.standard, initial: initialValue)
	}

	public var wrappedValue: Value {
		@inline(__always)
		get { projectedValue.value }
		@inline(__always)
		set { projectedValue.value = newValue }
	}
}

extension UserDefault {
	public final class Publisher<Output: UserDefaultable>: NSObject, Combine.Publisher {
		public typealias Failure = Never

		private let key: String
		private let store: UserDefaults
		private let initialValue: Output?
		private let subject: CurrentValueSubject<Output, Never>

		public var value: Output {
			@inline(__always)
			get { subject.value }
			@inline(__always)
			set {
				if subject.value != newValue {
					subject.value = newValue
					Output.set(newValue, for: key, in: store)
				}
			}
		}

		init(_ key: String,
			 in store: UserDefaults? = nil,
			 initial initialValue: Output? = nil) {
			let store = store ?? UserDefaults.standard

			self.key = key
			self.store = store
			self.initialValue = initialValue
			self.subject = CurrentValueSubject(Output.get(for: key, in: store, initial: initialValue))
			super.init()

			store.addObserver(self, forKeyPath: key, options: .new, context: nil)
		}

		deinit {
			self.store.removeObserver(self, forKeyPath: key)
		}

		public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
			if keyPath == key {
				let internalValue = change?[.newKey] as? Output.Internal
				let value = internalValue.flatMap(Output.init(userDefaultable:)) ?? initialValue ?? Output.defaultValue
				subject.send(value)
			}
		}

		public final func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Output == S.Input {
			subject.receive(subscriber: subscriber)
		}
	}
}
