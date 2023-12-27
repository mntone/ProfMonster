import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct WeaknessItemViewModel: Identifiable {
	let attack: Attack
	let effective: Effective
	let value: Float

	init(attack: Attack, effective: Effective, value: Float) {
		self.attack = attack
		self.effective = effective
		self.value = value
	}

	init(attack: Attack, value: Float, top: Float) {
		self.attack = attack
		if (value >= 10) {
			if (value == top) {
				self.effective = .high
			} else {
				self.effective = .middle
			}
		} else if value <= 0 {
			self.effective = .none
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
		case .low, .none:
			return .secondary
		}
	}

	var signWeight: Font.Weight {
		switch effective {
		case .high, .middle:
			return .bold
		case .low, .none:
			return .semibold
		}
	}
}

struct WeaknessSectionViewModel: Identifiable {
	let header: String
	let items: [WeaknessItemViewModel]

	init(header: String,
		 items: [WeaknessItemViewModel]) {
		self.header = header
		self.items = items
	}

	init(rawValue: PhysiologySection,
		 of attacks: [Attack] = Attack.allElements) {
		self.header = rawValue.label

		let val = rawValue.average.values(of: attacks)
		let top = val.max() ?? 0
		self.items = zip(attacks, val).map { attack, val in
			WeaknessItemViewModel(attack: attack, value: val, top: top)
		}
	}

	var id: String {
		header
	}
}

struct WeaknessViewModel {
	let sections: [WeaknessSectionViewModel]

	init(sections: [WeaknessSectionViewModel]) {
		self.sections = sections
	}

	init(rawValue: Physiologies,
		 of attacks: [Attack] = Attack.allElements) {
		self.sections = rawValue.sections.enumerated().map { id, rawValue in
			WeaknessSectionViewModel(rawValue: rawValue, of: attacks)
		}
	}
}
