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
	private static let separator: String = {
		String(localized: "/")
	}()

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
		var sections = physiology.states.map { section in
			NumberWeaknessSectionViewModel(prefixID: id,
										   physiology: section,
										   options: options)
		}

		// Merge objects with same value.
		var i = sections.count - 1
		while i >= 0 {
			let a = sections[i]
			for j in 0..<i {
				let b = sections[j]
				if a == b {
					if a.isDefault {
						sections[j] = b
					} else if !b.isDefault {
						let header = b.header + Self.separator + a.header
						sections[j] = NumberWeaknessSectionViewModel(header: header,
																	 isDefault: false,
																	 from: a)
					}
					sections.remove(at: i)
					break
				}
			}
			i = i - 1
		}
		self.sections = sections
		self.options = options
	}
}
