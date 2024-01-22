import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyValueViewModel: Identifiable {
	let attack: Attack
	let value: Int8
	let foregroundStyle: any ShapeStyle

	init(attack: Attack, value: Int8, level: Int) {
		self.attack = attack
		self.value = value
		switch attack {
		case .slash, .impact, .shot:
			if value >= 45 {
				self.foregroundStyle = TintShapeStyle().backport.hierarchical(level)
			} else {
				self.foregroundStyle = ForegroundStyle().backport.hierarchical(level)
			}
		case .fire, .water, .thunder, .ice, .dragon:
			self.foregroundStyle = ForegroundStyle().backport.hierarchical(level)
		}

	}

	var id: UInt8 {
		attack.rawValue
	}
}

struct PhysiologyViewModel: Identifiable {
	let id: UInt32
	let stateInfo: PhysiologyStateInfo
	let header: String
	let accessibilityHeader: String
	let values: [PhysiologyValueViewModel]
	let stun: Int8
	let isReference: Bool
	let hierarchical: HierarchicalShapeStyle

	fileprivate init(id: Int,
					 partsLabel: String,
					 rawValue: PhysiologyPart,
					 of attacks: [Attack],
					 isReference: Bool) {
		let level = Self.resolveHierarchicalLevel(rawValue.stateInfo, isReference: isReference)
		self.id = UInt32(exactly: id)!
		self.stateInfo = rawValue.stateInfo
		self.header = rawValue.isDefault ? partsLabel : rawValue.label
		self.accessibilityHeader = "\(partsLabel) \(rawValue.label)"
		self.values = zip(attacks, rawValue.value.values(of: attacks)).map { attack, value in
			PhysiologyValueViewModel(attack: attack, value: value, level: level)
		}
		self.stun = rawValue.stun
		self.isReference = isReference
		self.hierarchical = .hierarchical(level)
	}

	var stunLabel: String {
		switch stun {
		case 120:
			String(localized: "6/5", comment: "Stun")
		case 100:
			String(localized: "1", comment: "Stun")
		case 80:
			String(localized: "4/5", comment: "Stun")
		case 75:
			String(localized: "3/4", comment: "Stun")
		case 50:
			String(localized: "1/2", comment: "Stun")
		case 25:
			String(localized: "1/4", comment: "Stun")
		default:
			""
		}
	}

	private static func resolveHierarchicalLevel(_ stateInfo: PhysiologyStateInfo, isReference: Bool) -> Int {
		if stateInfo == .default {
			if isReference {
				1
			} else {
				0
			}
		} else {
			if isReference {
				2
			} else {
				1
			}
		}
	}
}

struct PhysiologyGroupViewModel: Identifiable {
	let id: UInt16
	let label: String
	let items: [PhysiologyViewModel]

	fileprivate init(id: Int, rawValue: PhysiologyParts, of attacks: [Attack]) {
		self.id = UInt16(exactly: id)!
		self.label = rawValue.label
		self.items = rawValue.items.enumerated().map { i, item in
			PhysiologyViewModel(id: id << 16 | i,
								partsLabel: rawValue.label,
								rawValue: item,
								of: attacks,
								isReference: rawValue.isReference)
		}
	}
}

struct PhysiologyColumnViewModel: Identifiable {
	let attack: Attack

	var id: UInt8 {
		attack.rawValue
	}
}

struct PhysiologySectionViewModel: Identifiable {
	let header: String
	let columns: [PhysiologyColumnViewModel]
	let groups: [PhysiologyGroupViewModel]
	let isDefault: Bool

	init(rawValue: PhysiologyStateGroup, of attacks: [Attack]) {
		self.header = rawValue.label
		self.columns = attacks.map(PhysiologyColumnViewModel.init(attack:))
		self.groups = rawValue.parts.enumerated().map { i, group in
			PhysiologyGroupViewModel(id: i, rawValue: group, of: attacks)
		}
		self.isDefault = rawValue.key == "default"
	}

	var id: String {
		header
	}
}

struct PhysiologiesViewModel: Identifiable {
	let id: String
	let sections: [PhysiologySectionViewModel]

	init(rawValue: Physiology, of attacks: [Attack] = Attack.allCases) {
		self.id = rawValue.id
		self.sections = rawValue.states.map { section in
			PhysiologySectionViewModel(rawValue: section, of: attacks)
		}
	}
}
