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

	public func values(of attacks: [Attack] = Attack.allCases) -> [Number] {
		attacks.map(value(of:))
	}
}

public struct Physiology: Hashable {
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

public struct PhysiologyGroup {
	public let parts: [String]
	public let label: String
	public let items: [Physiology]
	public let isReference: Bool
}

public struct PhysiologySection {
#if os(macOS) || arch(x86_64)
	public typealias AverageFloat = Float32
#else
	public typealias AverageFloat = Float16
#endif

	public let key: String
	public let label: String
	public let groups: [PhysiologyGroup]
	public let average: PhysiologyValue<AverageFloat>
}

public struct Physiologies: Identifiable {
	public let id: String
	public let sections: [PhysiologySection]
}
