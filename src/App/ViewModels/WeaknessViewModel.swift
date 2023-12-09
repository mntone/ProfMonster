import Foundation
import MonsterAnalyzerCore
import SwiftUI

struct WeaknessItemViewModel: Identifiable, AttackItemViewModel {
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

	var signKey: LocalizedStringKey {
		return LocalizedStringKey("effectiveSign." + effective.rawValue)
	}
}

struct WeaknessViewModel: Identifiable, AttackViewModel {
	let id: String
	let items: [WeaknessItemViewModel]

	init(_ id: String,
		 items: [WeaknessItemViewModel]) {
		self.id = id
		self.items = items
	}

	init(monster: MHMonster,
		 for attacks: [Attack] = Attack.allElements) {
		self.id = monster.id

		let val = monster.getAverages(of: attacks)
		let top = val.max() ?? 0
		self.items = zip(attacks, val).map { attack, val in
			WeaknessItemViewModel(attack: attack, value: val, top: top)
		}
	}
}

extension MHMonster {
	func createWeakness() -> WeaknessViewModel {
		return WeaknessViewModel(monster: self)
	}
}
