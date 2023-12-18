import Foundation

public enum PhysiologyStateInfo {
	case `default`
	case broken
	case other
}

public struct PhysiologyValue<Number> {
	public let slash: Number
	public let strike: Number
	public let shell: Number

	public let fire: Number
	public let water: Number
	public let thunder: Number
	public let ice: Number
	public let dragon: Number

	public func value(of attack: Attack) -> Number {
		switch attack {
		case .slash:
			return slash
		case .strike:
			return strike
		case .shell:
			return shell
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

public struct Physiology {
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
}

public struct PhysiologySection {
	public let label: String
	public let groups: [PhysiologyGroup]
	public let average: PhysiologyValue<Float>
}

public struct Physiologies: Identifiable {
	public let id: String
	public let sections: [PhysiologySection]
}
