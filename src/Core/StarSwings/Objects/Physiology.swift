import Foundation

public enum PhysiologyStateInfo: Int8 {
	case `default`
	case broken
	case other
}

public struct PhysiologyValue<Number>: Hashable where Number: Hashable, Number: Numeric {
	public let slash: Number
	public let impact: Number
	public let shot: Number

	public let fire: Number
	public let water: Number
	public let thunder: Number
	public let ice: Number
	public let dragon: Number

	public func value(of physical: Physical) -> Number {
		switch physical {
		case .slash:
			return slash
		case .impact:
			return impact
		case .shot:
			return shot
		}
	}

	public func value(of element: Element) -> Number {
		switch element {
		case .fire:
			return fire
		case .water:
			return water
		case .thunder:
			return thunder
		case .ice:
			return ice
		case .dragon:
			return dragon
		}
	}

	public func value(of attack: Attack) -> Number {
		switch attack {
		case .slash:
			return slash
		case .impact:
			return impact
		case .shot:
			return shot
		case .fire:
			return fire
		case .water:
			return water
		case .thunder:
			return thunder
		case .ice:
			return ice
		case .dragon:
			return dragon
		}
	}

	public func values(of elements: [Element] = Element.allCases) -> [Number] {
		elements.map(value(of:))
	}

	public func values(of attacks: [Attack] = Attack.allCases) -> [Number] {
		attacks.map(value(of:))
	}
}

public struct PhysiologyPart: Hashable {
	public let keys: [String]?
	public let stateInfo: PhysiologyStateInfo
	public let label: String
	public let value: PhysiologyValue<Int8>
	public let stun: Int8

	public var isDefault: Bool {
		if case .default = stateInfo {
			true
		} else {
			false
		}
	}

	public var isBroken: Bool {
		if case .broken = stateInfo {
			true
		} else {
			false
		}
	}
}

public struct PhysiologyParts {
	public let keys: [String]
	public let label: String
	public let items: [PhysiologyPart]
	public let isReference: Bool
}

public struct PhysiologyStateGroup {
#if os(macOS) || arch(x86_64)
	public typealias AverageFloat = Float32
#else
	public typealias AverageFloat = Float16
#endif

	public let key: String
	public let label: String
	public let parts: [PhysiologyParts]
	public let average: PhysiologyValue<AverageFloat>

	public var isDefault: Bool {
		key == "default"
	}
}

public struct Physiology: Identifiable {
	public let id: String
	public let mode: Mode
	public let states: [PhysiologyStateGroup]
}

public struct Physiologies: Identifiable {
	public let id: String
	public let version: String
	public let modes: [Physiology]
}
