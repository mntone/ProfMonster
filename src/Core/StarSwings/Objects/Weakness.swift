import Foundation

public struct Weakness {
	public let packedValue: UInt16

	init(packedValue: UInt16) {
		self.packedValue = packedValue
	}

	init?(string: String) {
		guard string.count >= 5 else {
			return nil
		}

		var index = string.startIndex
		var packedValue: UInt16 = 0
		packedValue = packedValue | Self.getEffectiveness(string[index], effective: "f", mostEffective: "F")

		index = string.index(index, offsetBy: 1)
		packedValue = packedValue | Self.getEffectiveness(string[index], effective: "w", mostEffective: "W") << 2

		index = string.index(index, offsetBy: 1)
		packedValue = packedValue | Self.getEffectiveness(string[index], effective: "t", mostEffective: "T") << 4

		index = string.index(index, offsetBy: 1)
		packedValue = packedValue | Self.getEffectiveness(string[index], effective: "i", mostEffective: "I") << 6

		index = string.index(index, offsetBy: 1)
		packedValue = packedValue | Self.getEffectiveness(string[index], effective: "d", mostEffective: "D") << 8

		self.packedValue = packedValue
	}

	public var fire: Effectiveness {
		@inline(__always)
		get {
			Effectiveness(rawValue: (packedValue & 0x0003))!
		}
	}

	public var water: Effectiveness {
		@inline(__always)
		get {
			Effectiveness(rawValue: (packedValue & 0x000C) >> 2)!
		}
	}

	public var thunder: Effectiveness {
		@inline(__always)
		get {
			Effectiveness(rawValue: (packedValue & 0x0030) >> 4)!
		}
	}

	public var ice: Effectiveness {
		@inline(__always)
		get {
			Effectiveness(rawValue: (packedValue & 0x00C0) >> 6)!
		}
	}

	public var dragon: Effectiveness {
		@inline(__always)
		get {
			Effectiveness(rawValue: (packedValue & 0x0300) >> 8)!
		}
	}

	private static func getEffectiveness(_ value: Character,
										 effective: Character,
										 mostEffective: Character) -> UInt16 {
		switch value {
		case mostEffective:
			0b11
		case effective:
			0b01
		default:
			0b00
		}
	}
}

// MARK: - CustomDebugStringConvertible

extension Weakness: CustomDebugStringConvertible  {
	public var debugDescription: String {
		return "\(fire.description("f", most: "F"))\(water.description("w", most: "W"))\(thunder.description("t", most: "T"))\(ice.description("i", most: "I"))\(dragon.description("d", most: "D"))"
	}
}
