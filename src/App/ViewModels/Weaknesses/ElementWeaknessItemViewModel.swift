import enum MonsterAnalyzerCore.Effectiveness
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import SwiftUI

struct ElementWeaknessItemViewModel: Identifiable, Hashable {
	typealias AverageFloat = PhysiologyStateGroup.AverageFloat

	let id: String
	let element: Element
	let effectiveness: Effectiveness
	let average: AverageFloat?

	init(id: String,
		 element: Element,
		 effectiveness: Effectiveness,
		 average: AverageFloat?) {
		self.id = id
		self.element = element
		self.effectiveness = effectiveness
		self.average = average
	}

	init(prefixID: String,
		 element: Element,
		 effectiveness: Effectiveness) {
		self.id = "\(prefixID):\(element.prefix)"
		self.element = element
		self.effectiveness = effectiveness
		self.average = nil
	}

	init(prefixID: String,
		 element: Element,
		 averageValue: AverageFloat,
		 topValue: AverageFloat) {
		self.id = "\(prefixID):\(element.prefix)"
		self.element = element
		switch averageValue {
		case topValue:
			self.effectiveness = .mostEffective
		case 10...:
			self.effectiveness = .effective
		case ...0:
			self.effectiveness = .ineffective
		default:
			self.effectiveness = .hardlyEffective
		}
		self.average = averageValue
	}

	static func compareEffectiveness(_ lhs: ElementWeaknessItemViewModel, _ rhs: ElementWeaknessItemViewModel) -> Bool {
		lhs.effectiveness == rhs.effectiveness
	}
}

extension ElementWeaknessItemViewModel {
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

extension ElementWeaknessItemViewModel: Equatable {
	static func == (lhs: ElementWeaknessItemViewModel, rhs: ElementWeaknessItemViewModel) -> Bool {
		switch (lhs.average, rhs.average) {
		case let (.some(a), .some(b)):
			a.isEqual(to: b)
		case (.none, .none):
			true
		default:
			false
		}
	}
}
