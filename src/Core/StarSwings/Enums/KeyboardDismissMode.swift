#if os(iOS)

import class Foundation.UserDefaults

@available(macOS, unavailable)
@available(watchOS, unavailable)
public enum KeyboardDismissMode: String, CaseIterable, Hashable {
	case button = "Button"
	case scroll = "Scroll"
	case swipe = "Swipe"
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension KeyboardDismissMode: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: KeyboardDismissMode {
		.button
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return KeyboardDismissMode(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}

#endif
