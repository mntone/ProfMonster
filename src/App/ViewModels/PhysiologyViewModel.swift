import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyViewModel: Identifiable {
	let id: String
	let parts: [String]

	private let rawValue: Physiology

	init(_ parts: [String], rawValue: Physiology) {
		self.id = "\(parts.joined(separator: "+"))&\(rawValue.states.joined(separator: "+"))"
		self.parts = parts
		self.rawValue = rawValue
	}

	var value: PhysiologyValue<Int8> {
		rawValue.value
	}

	var header: String {
		switch rawValue.stateInfo {
		case .default:
			return parts.map { part in
				String(localized: String.LocalizationValue("part." + part))
			}.joined(separator: String(localized: "part.separator"))
		default:
			return rawValue.states.joined(separator: String(localized: "part.separator"))
		}
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
	let id: String
	let items: [PhysiologyViewModel]

	init(rawValue: PhysiologyGroup) {
		self.id = rawValue.parts.joined(separator: "+")
		self.items = rawValue.items.map { item in
			PhysiologyViewModel(rawValue.parts, rawValue: item)
		}
	}
}

struct PhysiologySectionViewModel: Identifiable {
	let state: String
	let groups: [PhysiologyGroupViewModel]

	init(rawValue: PhysiologySection) {
		self.state = rawValue.state
		self.groups = rawValue.groups.map(PhysiologyGroupViewModel.init(rawValue:))
	}

	var id: String {
		state
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
