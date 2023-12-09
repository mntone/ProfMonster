import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct PhysiologyItemViewModel: Identifiable {
	let id: String
	let parts: [String]
	let state: PhysiologyState
	let values: [Int8]

	init(parts: [String], state: PhysiologyState, values: [Int8]) {
		self.id = parts.joined(separator: "&") + "." + state.rawValue
		self.parts = parts
		self.state = state
		self.values = values
	}

	var header: String {
		switch state {
		case .unknown, .default:
			return parts.map { part in
				String(localized: String.LocalizationValue("part." + part))
			}.joined(separator: String(localized: "part.separator"))
		default:
			return String(localized: String.LocalizationValue("state." + state.rawValue))
		}
	}

	var foregroundColor: Color {
		switch state {
		case .angry:
			return .red
		case .distending:
			return .green
		case .guarding:
			return .indigo
		case .mud:
			return .brown
		case .postbreak:
			return .teal
		case .rolling:
			return .cyan
		default:
			return .primary
		}
	}
}

struct PhysiologySectionViewModel: Identifiable {
	let id: String
	let parts: [String]
	let items: [PhysiologyItemViewModel]

	init(parts: [String], items: [PhysiologyItemViewModel]) {
		self.id = parts.joined(separator: "&")
		self.parts = parts
		self.items = items
	}
}

struct PhysiologyViewModel: Identifiable {
	let id: String
	let sections: [PhysiologySectionViewModel]

	init(_ id: String,
		 sections: [PhysiologySectionViewModel]) {
		self.id = id
		self.sections = sections
	}

	init(monster: MHMonster,
		 for attacks: [Attack] = Attack.allCases) {
		self.id = monster.id
		self.sections = monster.physiologies
			.map { physiology in
				PhysiologySectionViewModel(
					parts: physiology.parts,
					items: physiology.values.map { value in
						PhysiologyItemViewModel(
							parts: physiology.parts,
							state: PhysiologyState(rawValue: value.state) ?? .unknown,
							values: value.getValues(for: attacks))
						})
			}
	}
}

extension MHMonster {
	func createPhysiology() -> PhysiologyViewModel {
		return PhysiologyViewModel(monster: self)
	}
}
