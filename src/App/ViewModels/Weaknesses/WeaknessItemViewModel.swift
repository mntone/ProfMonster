import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Effectiveness
import struct MonsterAnalyzerCore.PhysiologySection
import SwiftUI

protocol WeaknessItemViewModel: Identifiable {
	typealias AverageFloat = PhysiologySection.AverageFloat

	var attack: Attack { get }
	var effectiveness: Effectiveness { get }
	var averageValueOrNil: AverageFloat? { get }
}

extension WeaknessItemViewModel {
	var signColor: Color {
		switch effectiveness {
		case .mostEffective, .effective:
			return .accentColor
		case .hardlyEffective, .ineffective:
			return .secondary
		}
	}

	var signWeight: Font.Weight {
		switch effectiveness {
		case .mostEffective, .effective:
			return .bold
		case .hardlyEffective, .ineffective:
			return .semibold
		}
	}
}

struct EffectivenessWeaknessItemViewModel: WeaknessItemViewModel {
	let id: String
	let attack: Attack
	let effectiveness: Effectiveness

	var averageValueOrNil: AverageFloat? {
		nil
	}

	init(id: String,
		 attack: Attack,
		 effectiveness: Effectiveness) {
		self.id = id
		self.attack = attack
		self.effectiveness = effectiveness
	}

	init(prefixID: String,
		 attack: Attack,
		 effectiveness: Effectiveness) {
		self.id = "\(prefixID):\(attack.prefix)"
		self.attack = attack
		self.effectiveness = effectiveness
	}
}

struct NumberWeaknessItemViewModel: WeaknessItemViewModel {
	let id: String
	let attack: Attack
	let effectiveness: Effectiveness
	let averageValue: AverageFloat

	var averageValueOrNil: AverageFloat? {
		averageValue
	}

	init(prefixID: String,
		 attack: Attack,
		 effective: Effectiveness,
		 averageValue: AverageFloat) {
		self.id = "\(prefixID):\(attack.prefix)"
		self.attack = attack
		self.effectiveness = effective
		self.averageValue = averageValue
	}

	init(prefixID: String,
		 attack: Attack,
		 averageValue: AverageFloat,
		 topValue: AverageFloat) {
		self.id = "\(prefixID):\(attack.prefix)"
		self.attack = attack
		switch averageValue {
		case 10...:
			if (averageValue == topValue) {
				self.effectiveness = .mostEffective
			} else {
				self.effectiveness = .effective
			}
		case ...0:
			self.effectiveness = .ineffective
		default:
			self.effectiveness = .hardlyEffective
		}
		self.averageValue = averageValue
	}
}
