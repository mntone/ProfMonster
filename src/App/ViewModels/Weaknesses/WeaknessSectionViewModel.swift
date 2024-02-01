import enum MonsterAnalyzerCore.Attack
import enum MonsterAnalyzerCore.Element
import struct MonsterAnalyzerCore.PhysiologyStateGroup
import struct MonsterAnalyzerCore.Weakness

struct PhysicalWeaknessSectionViewModel: Hashable {
	let slash: PhysicalWeaknessItemViewModel
	let impact: PhysicalWeaknessItemViewModel
	let shot: PhysicalWeaknessItemViewModel
}

struct ElementWeaknessSectionViewModel<ViewModel: WeaknessItemViewModel> {
	let fire: ViewModel
	let water: ViewModel
	let thunder: ViewModel
	let ice: ViewModel
	let dragon: ViewModel
}

extension ElementWeaknessSectionViewModel where ViewModel == NumberWeaknessItemViewModel {
	static func compareEffectiveness(_ lhs: ElementWeaknessSectionViewModel, _ rhs: ElementWeaknessSectionViewModel) -> Bool {
		NumberWeaknessItemViewModel.compareEffectiveness(lhs.fire, rhs.fire)
		&& NumberWeaknessItemViewModel.compareEffectiveness(lhs.water, rhs.water)
		&& NumberWeaknessItemViewModel.compareEffectiveness(lhs.thunder, rhs.thunder)
		&& NumberWeaknessItemViewModel.compareEffectiveness(lhs.ice, rhs.ice)
		&& NumberWeaknessItemViewModel.compareEffectiveness(lhs.dragon, rhs.dragon)
	}
}

extension ElementWeaknessSectionViewModel: Equatable where ViewModel == NumberWeaknessItemViewModel {
	static func ==(lhs: ElementWeaknessSectionViewModel, rhs: ElementWeaknessSectionViewModel) -> Bool {
		lhs.fire == rhs.fire
		&& lhs.water == rhs.water
		&& lhs.thunder == rhs.thunder
		&& lhs.ice == rhs.ice
		&& lhs.dragon == rhs.dragon
	}
}

protocol WeaknessSectionViewModel: Identifiable {
	associatedtype Item: WeaknessItemViewModel

	var header: String { get }
	var physical: PhysicalWeaknessSectionViewModel? { get }
	var elements: ElementWeaknessSectionViewModel<Item>? { get }
	var isDefault: Bool { get }
	var options: MonsterDataViewModelBuildOptions { get }
}

struct EffectivenessWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let elements: ElementWeaknessSectionViewModel<EffectivenessWeaknessItemViewModel>?
	let options: MonsterDataViewModelBuildOptions

	var physical: PhysicalWeaknessSectionViewModel? {
		nil
	}

	init(id: String,
		 header: String,
		 elements: ElementWeaknessSectionViewModel<EffectivenessWeaknessItemViewModel>?,
		 isDefault: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
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
		if options.element != .none {
			self.elements = ElementWeaknessSectionViewModel(
				fire: EffectivenessWeaknessItemViewModel(prefixID: id, element: .fire, effectiveness: weakness.fire),
				water: EffectivenessWeaknessItemViewModel(prefixID: id, element: .water, effectiveness: weakness.water),
				thunder: EffectivenessWeaknessItemViewModel(prefixID: id, element: .thunder, effectiveness: weakness.thunder),
				ice: EffectivenessWeaknessItemViewModel(prefixID: id, element: .ice, effectiveness: weakness.ice),
				dragon: EffectivenessWeaknessItemViewModel(prefixID: id, element: .dragon, effectiveness: weakness.dragon))
		} else {
			self.elements = nil
		}
		self.options = options
	}
}

struct NumberWeaknessSectionViewModel: WeaknessSectionViewModel {
	let id: String
	let header: String
	let isDefault: Bool
	let physical: PhysicalWeaknessSectionViewModel?
	let elements: ElementWeaknessSectionViewModel<NumberWeaknessItemViewModel>?
	let options: MonsterDataViewModelBuildOptions

	init(id: String,
		 header: String,
		 physical: PhysicalWeaknessSectionViewModel?,
		 elements: ElementWeaknessSectionViewModel<NumberWeaknessItemViewModel>?,
		 isDefault: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.header = header
		self.isDefault = isDefault
		self.physical = physical
		self.elements = elements
		self.options = options
	}

	init(header: String,
		 isDefault: Bool,
		 from base: NumberWeaknessSectionViewModel) {
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
				fire: NumberWeaknessItemViewModel(prefixID: id, element: .fire, averageValue: physiology.average.fire, topValue: top),
				water: NumberWeaknessItemViewModel(prefixID: id, element: .water, averageValue: physiology.average.water, topValue: top),
				thunder: NumberWeaknessItemViewModel(prefixID: id, element: .thunder, averageValue: physiology.average.thunder, topValue: top),
				ice: NumberWeaknessItemViewModel(prefixID: id, element: .ice, averageValue: physiology.average.ice, topValue: top),
				dragon: NumberWeaknessItemViewModel(prefixID: id, element: .dragon, averageValue: physiology.average.dragon, topValue: top))
		} else {
			self.elements = nil
		}

		self.options = options
	}
}

extension NumberWeaknessSectionViewModel: Equatable {
	static func ==(lhs: NumberWeaknessSectionViewModel, rhs: NumberWeaknessSectionViewModel) -> Bool {
		precondition(lhs.options.element == rhs.options.element)

		let physical: Bool
		if lhs.options.physical {
			physical = lhs.physical == rhs.physical
		} else {
			physical = true
		}
		if lhs.options.element == .sign {
			if !physical {
				return false
			} else if let a = lhs.elements, let b = rhs.elements {
				return ElementWeaknessSectionViewModel.compareEffectiveness(a, b)
			} else {
				return false
			}
		} else {
			return physical && lhs.elements == rhs.elements
		}
	}
}
