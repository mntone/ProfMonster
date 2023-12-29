import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyValueViewModel: Identifiable {
	let attack: Attack
	let value: Int8

	var id: String {
		attack.rawValue
	}
}

struct PhysiologyViewModel: Identifiable {
	let id: UInt32
	let stateInfo: PhysiologyStateInfo
	let header: String
	let values: [PhysiologyValueViewModel]
	let stun: Int8
	let isReference: Bool

	fileprivate init(id: Int,
					 partsLabel: String,
					 rawValue: Physiology,
					 of attacks: [Attack],
					 isReference: Bool) {
		self.id = UInt32(exactly: id)!
		self.stateInfo = rawValue.stateInfo
		self.header = rawValue.isDefault ? partsLabel : rawValue.label
		self.values = zip(attacks, rawValue.value.values(of: attacks)).map(PhysiologyValueViewModel.init)
		self.stun = rawValue.stun
		self.isReference = isReference
	}

	var stunLabel: String {
		switch stun {
		case 120:
			String(localized: "6/5")
		case 100:
			String(localized: "1")
		case 80:
			String(localized: "4/5")
		case 75:
			String(localized: "3/4")
		case 50:
			String(localized: "1/2")
		default:
			""
		}
	}

	var foregroundShape: AnyShapeStyle {
		switch stateInfo {
		case .default:
			return AnyShapeStyle(isReference ? .secondary : .primary)
		case .broken:
			return AnyShapeStyle(.tint)
		case .other:
			return AnyShapeStyle(isReference ? .tertiary : .secondary)
		}
	}
}

struct PhysiologyGroupViewModel: Identifiable {
	let id: UInt16
	let label: String
	let items: [PhysiologyViewModel]

	fileprivate init(id: Int, rawValue: PhysiologyGroup, of attacks: [Attack]) {
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

	var id: String {
		attack.rawValue
	}
}

struct PhysiologySectionViewModel: Identifiable {
	let header: String
	let columns: [PhysiologyColumnViewModel]
	let groups: [PhysiologyGroupViewModel]

	init(rawValue: PhysiologySection, of attacks: [Attack]) {
		self.header = rawValue.label
		self.columns = attacks.map(PhysiologyColumnViewModel.init(attack:))
		self.groups = rawValue.groups.enumerated().map { i, group in
			PhysiologyGroupViewModel(id: i, rawValue: group, of: attacks)
		}
	}

	var id: String {
		header
	}
}

struct PhysiologiesViewModel: Identifiable {
	let id: String
	let sections: [PhysiologySectionViewModel]

	init(rawValue: Physiologies, of attacks: [Attack] = Attack.allCases) {
		self.id = rawValue.id
		self.sections = rawValue.sections.map { section in
			PhysiologySectionViewModel(rawValue: section, of: attacks)
		}
	}
}
