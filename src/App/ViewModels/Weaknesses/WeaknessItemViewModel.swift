import enum MonsterAnalyzerCore.Effectiveness
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import SwiftUI

protocol WeaknessItemViewModel: Identifiable {
	typealias AverageFloat = PhysiologyStateGroup.AverageFloat

	var element: Element { get }
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
	let element: Element
	let effectiveness: Effectiveness

	var averageValueOrNil: AverageFloat? {
		nil
	}

	init(id: String,
		 element: Element,
		 effectiveness: Effectiveness) {
		self.id = id
		self.element = element
		self.effectiveness = effectiveness
	}

	init(prefixID: String,
		 element: Element,
		 effectiveness: Effectiveness) {
		self.id = "\(prefixID):\(element.prefix)"
		self.element = element
		self.effectiveness = effectiveness
	}
}

struct NumberWeaknessItemViewModel: WeaknessItemViewModel {
	let id: String
	let element: Element
	let effectiveness: Effectiveness
	let averageValue: AverageFloat

	var averageValueOrNil: AverageFloat? {
		averageValue
	}

	init(prefixID: String,
		 element: Element,
		 effective: Effectiveness,
		 averageValue: AverageFloat) {
		self.id = "\(prefixID):\(element.prefix)"
		self.element = element
		self.effectiveness = effective
		self.averageValue = averageValue
	}

	init(prefixID: String,
		 element: Element,
		 averageValue: AverageFloat,
		 topValue: AverageFloat) {
		self.id = "\(prefixID):\(element.prefix)"
		self.element = element
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

	static func compareEffectiveness(lhs: NumberWeaknessItemViewModel, rhs: NumberWeaknessItemViewModel) -> Bool {
		lhs.effectiveness == rhs.effectiveness
	}
}
