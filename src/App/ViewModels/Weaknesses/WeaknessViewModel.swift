import enum MonsterAnalyzerCore.Attack
import struct MonsterAnalyzerCore.Physiology
import struct MonsterAnalyzerCore.Weakness

protocol WeaknessViewModel: Identifiable {
	associatedtype Section: WeaknessSectionViewModel

	var sections: [Section] { get }
	var options: MonsterDataViewModelBuildOptions { get }
}

struct EffectivenessWeaknessViewModel: WeaknessViewModel {
	let id: String
	let sections: [EffectivenessWeaknessSectionViewModel]
	let options: MonsterDataViewModelBuildOptions

	init(id: String,
		 sections: [EffectivenessWeaknessSectionViewModel],
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.sections = sections
		self.options = options
	}

	init(prefixID: String,
		 weakness weaknesses: [String: Weakness],
		 options: MonsterDataViewModelBuildOptions) {
		let id = "\(prefixID):w"
		self.id = id
		self.sections = weaknesses
			.map { key, weakness in
				EffectivenessWeaknessSectionViewModel(prefixID: id,
													  key: key,
													  weakness: weakness,
													  options: options)
			}
			.sorted { lhs, rhs in
				lhs.isDefault && !rhs.isDefault
			}
		self.options = options
	}
}

struct NumberWeaknessViewModel: WeaknessViewModel {
	let id: String
	let sections: [NumberWeaknessSectionViewModel]
	let options: MonsterDataViewModelBuildOptions

	init(id: String,
		 sections: [NumberWeaknessSectionViewModel],
		 options: MonsterDataViewModelBuildOptions) {
		self.id = id
		self.sections = sections
		self.options = options
	}

	init(prefixID: String,
		 physiology: Physiology,
		 options: MonsterDataViewModelBuildOptions) {
		let id = "\(prefixID):w"
		self.id = id
		self.sections = physiology.states.map { section in
			NumberWeaknessSectionViewModel(prefixID: id,
										   physiology: section,
										   options: options)
		}
		self.options = options
	}
}
