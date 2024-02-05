import class Foundation.UserDefaults

@available(macOS, unavailable)
@available(watchOS, unavailable)
public enum NavigationBarHideMode: String, CaseIterable, Hashable {
	case nothing = "NO"
	case editingLandscape = "EDTLS"
	case editing = "EDT"
}

@available(macOS, unavailable)
@available(watchOS, unavailable)
extension NavigationBarHideMode: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: NavigationBarHideMode {
		.editingLandscape
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return NavigationBarHideMode(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}
