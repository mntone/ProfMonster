import Foundation

public enum Effectiveness: UInt16 {
	case ineffective = 0b00
	case hardlyEffective = 0b01
	case effective = 0b10
	case mostEffective = 0b11

	func description(_ effective: Character, most mostEffective: Character) -> Character {
		switch self {
		case .mostEffective:
			mostEffective
		case .effective:
			effective
		case .hardlyEffective, .ineffective:
			"_"
		}
	}
}
