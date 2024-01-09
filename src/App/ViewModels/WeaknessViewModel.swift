import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct WeaknessItemViewModel: Identifiable {
	let attack: Attack
	let effective: Effective
	let value: PhysiologySection.AverageFloat

	init(attack: Attack, effective: Effective, value: PhysiologySection.AverageFloat) {
		self.attack = attack
		self.effective = effective
		self.value = value
	}

	init(attack: Attack, value: PhysiologySection.AverageFloat, top: PhysiologySection.AverageFloat) {
		self.attack = attack
		if (value >= 10) {
			if (value == top) {
				self.effective = .high
			} else {
				self.effective = .middle
			}
		} else if value <= 0 {
			self.effective = .invalid
		} else {
			self.effective = .low
		}
		self.value = value
	}

	var id: String {
		attack.rawValue
	}

	var signColor: Color {
		switch effective {
		case .high, .middle:
			return .accentColor
		case .low, .invalid:
			return .secondary
		}
	}

	var signWeight: Font.Weight {
		switch effective {
		case .high, .middle:
			return .bold
		case .low, .invalid:
			return .semibold
		}
	}
}

struct WeaknessSectionViewModel: Identifiable {
	let id: String
	let header: String
	let items: [WeaknessItemViewModel]

	init(id: String,
		 header: String,
		 items: [WeaknessItemViewModel]) {
		self.id = id
		self.header = header
		self.items = items
	}

	init(_ id: String,
		 rawValue: PhysiologySection,
		 of attacks: [Attack] = Attack.allElements) {
		self.id = "\(id):\(rawValue.label)"
		self.header = rawValue.label

		let val = rawValue.average.values(of: attacks)
		let top = val.max() ?? 0
		self.items = zip(attacks, val).map { attack, val in
			WeaknessItemViewModel(attack: attack, value: val, top: top)
		}
	}
}

struct WeaknessViewModel {
	let id: String
	let displayMode: WeaknessDisplayMode
	let sections: [WeaknessSectionViewModel]

	init(id: String,
		 displayMode: WeaknessDisplayMode,
		 sections: [WeaknessSectionViewModel]) {
		precondition(displayMode != .none)

		self.id = id
		self.displayMode = displayMode
		self.sections = sections
	}

	init(_ id: String,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiologies,
		 of attacks: [Attack] = Attack.allElements) {
		precondition(displayMode != .none)

		let myid = "\(id):w"
		self.id = myid
		self.displayMode = displayMode
		self.sections = rawValue.sections.enumerated().map { id, rawValue in
			WeaknessSectionViewModel(myid, rawValue: rawValue, of: attacks)
		}
	}
}
