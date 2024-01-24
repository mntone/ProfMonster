import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import struct MonsterAnalyzerCore.Weakness

struct PhysicalWeaknessSectionViewModel<ViewModel> {
	let slash: ViewModel
	let impact: ViewModel
	let shot: ViewModel
}

protocol WeaknessSectionViewModel: Identifiable {
	associatedtype PhysicalItem
	associatedtype Item: WeaknessItemViewModel

	var header: String { get }
	var physical: PhysicalWeaknessSectionViewModel<PhysicalItem>? { get }
	var items: [Item] { get }
	var isDefault: Bool { get }
}

struct EffectivenessWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let items: [EffectivenessWeaknessItemViewModel]

	var physical: PhysicalWeaknessSectionViewModel<Never>? {
		nil
	}

	init(id: String,
		 header: String,
		 items: [EffectivenessWeaknessItemViewModel],
		 isDefault: Bool) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.items = items
	}

	init(prefixID: String,
		 key: String,
		 rawValue: Weakness) {
		let id = "\(prefixID):\(key)"
		self.id = id
		self.header = rawValue.state
		self.isDefault = key == "default"
		self.items = Element.allCases.map { element in
			EffectivenessWeaknessItemViewModel(prefixID: id,
											   element: element,
											   effectiveness: rawValue.value(of: element))
		}
	}
}

struct NumberWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let physical: PhysicalWeaknessSectionViewModel<PhysicalWeaknessItemViewModel>?
	let items: [NumberWeaknessItemViewModel]

	init(id: String,
		 header: String,
		 physical: PhysicalWeaknessSectionViewModel<PhysicalWeaknessItemViewModel>?,
		 items: [NumberWeaknessItemViewModel],
		 isDefault: Bool) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.physical = physical
		self.items = items
	}

	init(prefixID: String,
		 rawValue: PhysiologyStateGroup) {
		let id = "\(prefixID):\(rawValue.key)"
		self.id = id
		self.header = rawValue.label
		self.isDefault = rawValue.key == "default"
		self.physical = PhysicalWeaknessSectionViewModel(
			slash: PhysicalWeaknessItemViewModel(prefixID: id, physical: .slash, stateGroup: rawValue),
			impact: PhysicalWeaknessItemViewModel(prefixID: id, physical: .impact, stateGroup: rawValue),
			shot: PhysicalWeaknessItemViewModel(prefixID: id, physical: .shot, stateGroup: rawValue))

		let elements = Element.allCases
		let val = rawValue.average.values(of: elements)
		let top = val.max() ?? 0
		self.items = zip(elements, val).map { element, val in
			NumberWeaknessItemViewModel(prefixID: id,
										element: element,
										averageValue: val,
										topValue: top)
		}
	}

	static func compareEffectiveness(lhs: NumberWeaknessSectionViewModel, rhs: NumberWeaknessSectionViewModel) -> Bool {
		zip(lhs.items, rhs.items).allSatisfy { lhs, rhs in
			NumberWeaknessItemViewModel.compareEffectiveness(lhs: lhs, rhs: rhs)
		}
	}
}
