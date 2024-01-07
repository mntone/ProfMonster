import Foundation

public enum WeaknessDisplayMode: CaseIterable, Hashable {
	case none
	case sign
	case number(fractionLength: UInt8)

	public init?(rawValue: String) {
		switch rawValue {
		case "None":
			self = .none
		case "Sign":
			self = .sign
		case "Number":
			self = .number(fractionLength: 1)
		default:
			if rawValue.count == 7,
			   rawValue.starts(with: "Number"),
			   let fractionLength = rawValue[rawValue.index(before: rawValue.endIndex)].wholeNumberValue.flatMap(UInt8.init) {
				self = .number(fractionLength: fractionLength)
			} else {
				return nil
			}
		}
	}

	public var rawValue: String {
		switch self {
		case .none:
			return "None"
		case .sign:
			return "Sign"
		case .number(1):
			return "Number"
		case let .number(fractionLength):
			return "Number\(fractionLength)"
		}
	}

	public static var allCases: [WeaknessDisplayMode] = [.none, .sign, .number(fractionLength: 1), .number(fractionLength: 2)]
}

extension WeaknessDisplayMode: UserDefaultable {
	public typealias Internal = String

	public static var defaultValue: WeaknessDisplayMode {
		.sign
	}

	public init?(userDefaultable value: String) {
		self.init(rawValue: value)
	}

	public static func get(for key: String, in store: UserDefaults, initial initialValue: Self?) -> Self {
		guard let value = store.string(forKey: key) else {
			return initialValue ?? defaultValue
		}
		return WeaknessDisplayMode(rawValue: value) ?? defaultValue
	}

	public static func set(_ newValue: Self, for key: String, in store: UserDefaults) {
		store.set(newValue.rawValue, forKey: key)
	}
}
