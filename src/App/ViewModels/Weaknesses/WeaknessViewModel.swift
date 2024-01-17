import enum MonsterAnalyzerCore.Attack
import struct MonsterAnalyzerCore.Physiologies
import struct MonsterAnalyzerCore.Weakness
import enum MonsterAnalyzerCore.WeaknessDisplayMode

protocol WeaknessViewModel: Identifiable {
	associatedtype Section: WeaknessSectionViewModel

	var displayMode: WeaknessDisplayMode { get }
	var sections: [Section] { get }
}

struct EffectivenessWeaknessViewModel: WeaknessViewModel {
	let id: String
	let displayMode: WeaknessDisplayMode
	let sections: [EffectivenessWeaknessSectionViewModel]

	init(id: String,
		 displayMode: WeaknessDisplayMode,
		 sections: [EffectivenessWeaknessSectionViewModel]) {
		precondition(displayMode != .none)

		self.id = id
		self.displayMode = displayMode
		self.sections = sections
	}

	init(prefixID: String,
		 displayMode: WeaknessDisplayMode,
		 rawValue: [String: Weakness],
		 of attacks: [Attack] = Attack.allElements) {
		precondition(displayMode != .none)

		let id = "\(prefixID):w"
		self.id = id
		self.displayMode = displayMode
		self.sections = rawValue.map { key, weakness in
			EffectivenessWeaknessSectionViewModel(prefixID: id,
												  key: key,
												  rawValue: weakness,
												  of: attacks)
		}
	}
}

struct NumberWeaknessViewModel: WeaknessViewModel {
	let id: String
	let displayMode: WeaknessDisplayMode
	let sections: [NumberWeaknessSectionViewModel]

	init(id: String,
		 displayMode: WeaknessDisplayMode,
		 sections: [NumberWeaknessSectionViewModel]) {
		precondition(displayMode != .none)

		self.id = id
		self.displayMode = displayMode
		self.sections = sections
	}

	init(prefixID: String,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiologies,
		 of attacks: [Attack] = Attack.allElements) {
		precondition(displayMode != .none)

		let id = "\(prefixID):w"
		self.id = id
		self.displayMode = displayMode
		self.sections = rawValue.sections.map { section in
			NumberWeaknessSectionViewModel(prefixID: id,
										   rawValue: section,
										   of: attacks)
		}
	}
}
