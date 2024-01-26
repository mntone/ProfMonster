import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import struct MonsterAnalyzerCore.Weakness

struct PhysicalWeaknessSectionViewModel: Hashable {
	let slash: PhysicalWeaknessItemViewModel
	let impact: PhysicalWeaknessItemViewModel
	let shot: PhysicalWeaknessItemViewModel
}

protocol WeaknessSectionViewModel: Identifiable, Hashable {
	associatedtype Item: WeaknessItemViewModel

	var header: String { get }
	var physical: PhysicalWeaknessSectionViewModel? { get }
	var items: [Item] { get }
	var isDefault: Bool { get }
	var options: MonsterDataViewModelBuildOptions { get }
}

struct EffectivenessWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let items: [EffectivenessWeaknessItemViewModel]
	let options: MonsterDataViewModelBuildOptions

	var physical: PhysicalWeaknessSectionViewModel? {
		nil
	}

	init(id: String,
		 header: String,
		 items: [EffectivenessWeaknessItemViewModel],
		 isDefault: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.items = items
		self.options = options
	}

	init(prefixID: String,
		 key: String,
		 weakness: Weakness,
		 options: MonsterDataViewModelBuildOptions) {
		let id = "\(prefixID):\(key)"
		self.id = id
		self.header = weakness.state
		self.isDefault = key == "default"
		if options.element != .none {
			self.items = Element.allCases.map { element in
				EffectivenessWeaknessItemViewModel(prefixID: id,
												   element: element,
												   effectiveness: weakness.value(of: element))
			}
		} else {
			self.items = []
		}
		self.options = options
	}
}

struct NumberWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let physical: PhysicalWeaknessSectionViewModel?
	let items: [NumberWeaknessItemViewModel]
	let options: MonsterDataViewModelBuildOptions

	init(id: String,
		 header: String,
		 physical: PhysicalWeaknessSectionViewModel?,
		 items: [NumberWeaknessItemViewModel],
		 isDefault: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.physical = physical
		self.items = items
		self.options = options
	}

	init(prefixID: String,
		 physiology: PhysiologyStateGroup,
		 options: MonsterDataViewModelBuildOptions) {
		let id = "\(prefixID):\(physiology.key)"
		self.id = id
		self.header = physiology.label
		self.isDefault = physiology.key == "default"

		if options.physical {
			self.physical = PhysicalWeaknessSectionViewModel(
				slash: PhysicalWeaknessItemViewModel(prefixID: id, physical: .slash, stateGroup: physiology),
				impact: PhysicalWeaknessItemViewModel(prefixID: id, physical: .impact, stateGroup: physiology),
				shot: PhysicalWeaknessItemViewModel(prefixID: id, physical: .shot, stateGroup: physiology))
		} else {
			self.physical = nil
		}

		if options.element != .none {
			let elements = Element.allCases
			let val = physiology.average.values(of: elements)
			let top = val.max() ?? 0
			self.items = zip(elements, val).map { element, val in
				NumberWeaknessItemViewModel(prefixID: id,
											element: element,
											averageValue: val,
											topValue: top)
			}
		} else {
			self.items = []
		}

		self.options = options
	}

	static func compareEffectiveness(lhs: NumberWeaknessSectionViewModel, rhs: NumberWeaknessSectionViewModel) -> Bool {
		zip(lhs.items, rhs.items).allSatisfy { lhs, rhs in
			NumberWeaknessItemViewModel.compareEffectiveness(lhs: lhs, rhs: rhs)
		}
	}
}
