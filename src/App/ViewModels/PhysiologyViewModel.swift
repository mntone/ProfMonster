import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyViewModel: Identifiable {
	let id: UInt32
	let stateInfo: PhysiologyStateInfo
	let header: String
	let values: [Int8]

	fileprivate init(id: Int,
					 partsLabel: String,
					 rawValue: Physiology,
					 of attacks: [Attack]) {
		self.id = UInt32(exactly: id)!
		self.stateInfo = rawValue.stateInfo
		self.header = rawValue.isDefault ? partsLabel : rawValue.label
		self.values = rawValue.value.values(of: attacks)
	}

	var foregroundColor: Color {
		switch stateInfo {
		case .default:
			return .primary
		case .broken:
			return .teal
		case .other:
			return .secondary
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
			PhysiologyViewModel(id: id << 16 | i, partsLabel: rawValue.label, rawValue: item, of: attacks)
		}
	}
}

struct PhysiologyColumnViewModel: Identifiable, AttackItemViewModel {
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
