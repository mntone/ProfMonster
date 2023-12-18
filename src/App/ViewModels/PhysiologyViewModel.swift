import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyViewModel: Identifiable {
	let id: UInt32
	let header: String

	private let rawValue: Physiology

	fileprivate init(id: Int,
					 partsLabel: String,
					 rawValue: Physiology) {
		self.id = UInt32(exactly: id)!
		self.header = rawValue.isDefault ? partsLabel : rawValue.label
		self.rawValue = rawValue
	}

	var value: PhysiologyValue<Int8> {
		rawValue.value
	}

	var foregroundColor: Color {
		switch rawValue.stateInfo {
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

	fileprivate init(id: Int, rawValue: PhysiologyGroup) {
		self.id = UInt16(exactly: id)!
		self.label = rawValue.label
		self.items = rawValue.items.enumerated().map { i, item in
			PhysiologyViewModel(id: id << 16 | i, partsLabel: rawValue.label, rawValue: item)
		}
	}
}

struct PhysiologySectionViewModel: Identifiable {
	let header: String
	let groups: [PhysiologyGroupViewModel]

	init(rawValue: PhysiologySection) {
		self.header = rawValue.label
		self.groups = rawValue.groups.enumerated().map(PhysiologyGroupViewModel.init(id:rawValue:))
	}

	var id: String {
		header
	}
}

struct PhysiologiesViewModel: Identifiable {
	let id: String
	let sections: [PhysiologySectionViewModel]

	init(rawValue: Physiologies) {
		self.id = rawValue.id
		self.sections = rawValue.sections.map(PhysiologySectionViewModel.init(rawValue:))
	}
}
