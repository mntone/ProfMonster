import enum MonsterAnalyzerCore.Attack
import struct MonsterAnalyzerCore.PhysiologySection
import struct MonsterAnalyzerCore.Weakness

protocol WeaknessSectionViewModel: Identifiable {
	associatedtype Item: WeaknessItemViewModel

	var header: String { get }
	var items: [Item] { get }
	var isDefault: Bool { get }
}

struct EffectivenessWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let items: [EffectivenessWeaknessItemViewModel]
	let isDefault: Bool

	init(id: String,
		 header: String,
		 items: [EffectivenessWeaknessItemViewModel],
		 isDefault: Bool) {
		self.id = id
		self.header = header
		self.items = items
		self.isDefault = isDefault
	}

	init(prefixID: String,
		 key: String,
		 rawValue: Weakness,
		 of attacks: [Attack] = Attack.allElements) {
		let id = "\(prefixID):\(key)"
		self.id = id
		self.header = rawValue.state

		self.items = attacks.map { attack in
			EffectivenessWeaknessItemViewModel(prefixID: id,
											   attack: attack,
											   effectiveness: rawValue.value(of: attack))
		}
		self.isDefault = key == "default"
	}
}

struct NumberWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let items: [NumberWeaknessItemViewModel]
	let isDefault: Bool

	init(id: String,
		 header: String,
		 items: [NumberWeaknessItemViewModel],
		 isDefault: Bool) {
		self.id = id
		self.header = header
		self.items = items
		self.isDefault = isDefault
	}

	init(prefixID: String,
		 rawValue: PhysiologySection,
		 of attacks: [Attack] = Attack.allElements) {
		let id = "\(prefixID):\(rawValue.label)"
		self.id = id
		self.header = rawValue.label

		let val = rawValue.average.values(of: attacks)
		let top = val.max() ?? 0
		self.items = zip(attacks, val).map { attack, val in
			NumberWeaknessItemViewModel(prefixID: id,
										attack: attack,
										averageValue: val,
										topValue: top)
		}
		self.isDefault = rawValue.key == "default"
	}

	static func compareEffectiveness(lhs: NumberWeaknessSectionViewModel, rhs: NumberWeaknessSectionViewModel) -> Bool {
		zip(lhs.items, rhs.items).allSatisfy { lhs, rhs in
			NumberWeaknessItemViewModel.compareEffectiveness(lhs: lhs, rhs: rhs)
		}
	}
}
