import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import struct MonsterAnalyzerCore.Weakness

struct PhysicalWeaknessSectionViewModel: Hashable {
	let slash: PhysicalWeaknessItemViewModel
	let impact: PhysicalWeaknessItemViewModel
	let shot: PhysicalWeaknessItemViewModel
}

struct ElementWeaknessSectionViewModel: Hashable {
	let fire: ElementWeaknessItemViewModel
	let water: ElementWeaknessItemViewModel
	let thunder: ElementWeaknessItemViewModel
	let ice: ElementWeaknessItemViewModel
	let dragon: ElementWeaknessItemViewModel

	static func compareEffectiveness(_ lhs: ElementWeaknessSectionViewModel, _ rhs: ElementWeaknessSectionViewModel) -> Bool {
		ElementWeaknessItemViewModel.compareEffectiveness(lhs.fire, rhs.fire)
		&& ElementWeaknessItemViewModel.compareEffectiveness(lhs.water, rhs.water)
		&& ElementWeaknessItemViewModel.compareEffectiveness(lhs.thunder, rhs.thunder)
		&& ElementWeaknessItemViewModel.compareEffectiveness(lhs.ice, rhs.ice)
		&& ElementWeaknessItemViewModel.compareEffectiveness(lhs.dragon, rhs.dragon)
	}

	static func compareNumber(_ lhs: ElementWeaknessSectionViewModel, _ rhs: ElementWeaknessSectionViewModel) -> Bool {
		ElementWeaknessItemViewModel.compareNumber(lhs.fire, rhs.fire)
		&& ElementWeaknessItemViewModel.compareNumber(lhs.water, rhs.water)
		&& ElementWeaknessItemViewModel.compareNumber(lhs.thunder, rhs.thunder)
		&& ElementWeaknessItemViewModel.compareNumber(lhs.ice, rhs.ice)
		&& ElementWeaknessItemViewModel.compareNumber(lhs.dragon, rhs.dragon)
	}
}

struct WeaknessSectionViewModel: Identifiable, Hashable {
	let id: String
	let header: String
	let isDefault: Bool
	let physical: PhysicalWeaknessSectionViewModel?
	let elements: ElementWeaknessSectionViewModel?
	let options: MonsterDataViewModelBuildOptions

	init(id: String,
		 header: String,
		 physical: PhysicalWeaknessSectionViewModel?,
		 elements: ElementWeaknessSectionViewModel?,
		 isDefault: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.physical = physical
		self.elements = elements
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
		self.physical = nil
		if options.element != .none {
			self.elements = ElementWeaknessSectionViewModel(
				fire: ElementWeaknessItemViewModel(prefixID: id, element: .fire, effectiveness: weakness.fire),
				water: ElementWeaknessItemViewModel(prefixID: id, element: .water, effectiveness: weakness.water),
				thunder: ElementWeaknessItemViewModel(prefixID: id, element: .thunder, effectiveness: weakness.thunder),
				ice: ElementWeaknessItemViewModel(prefixID: id, element: .ice, effectiveness: weakness.ice),
				dragon: ElementWeaknessItemViewModel(prefixID: id, element: .dragon, effectiveness: weakness.dragon))
		} else {
			self.elements = nil
		}
		self.options = options
	}

	init(header: String,
		 isDefault: Bool,
		 from base: WeaknessSectionViewModel) {
		self.id = base.id
		self.header = header
		self.isDefault = isDefault
		self.physical = base.physical
		self.elements = base.elements
		self.options = base.options
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
			self.elements = ElementWeaknessSectionViewModel(
				fire: ElementWeaknessItemViewModel(prefixID: id, element: .fire, averageValue: physiology.average.fire, topValue: top),
				water: ElementWeaknessItemViewModel(prefixID: id, element: .water, averageValue: physiology.average.water, topValue: top),
				thunder: ElementWeaknessItemViewModel(prefixID: id, element: .thunder, averageValue: physiology.average.thunder, topValue: top),
				ice: ElementWeaknessItemViewModel(prefixID: id, element: .ice, averageValue: physiology.average.ice, topValue: top),
				dragon: ElementWeaknessItemViewModel(prefixID: id, element: .dragon, averageValue: physiology.average.dragon, topValue: top))
		} else {
			self.elements = nil
		}

		self.options = options
	}

	static func compareContent(_ lhs: WeaknessSectionViewModel, _ rhs: WeaknessSectionViewModel) -> Bool {
		guard lhs.physical == rhs.physical else {
			return false
		}

		if let a = lhs.elements, let b = rhs.elements {
			if lhs.options.element == .sign {
				return ElementWeaknessSectionViewModel.compareEffectiveness(a, b)
			} else {
				return ElementWeaknessSectionViewModel.compareNumber(a, b)
			}
		} else {
			return false
		}
	}
}
