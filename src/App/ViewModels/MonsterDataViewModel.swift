import MonsterAnalyzerCore

struct MonsterDataViewModelBuildOptions: Hashable {
	let physical: Bool
	let element: ElementWeaknessDisplayMode

	@inline(__always)
	fileprivate var isHidden: Bool {
		!physical && element == .none
	}

	init(physical: Bool, element: ElementWeaknessDisplayMode) {
		self.physical = physical
		self.element = element
	}

	init(_ settings: MonsterAnalyzerCore.Settings) {
		self.physical = settings.showPhysicalAttack
		self.element = settings.elementAttack
	}
}

struct MonsterDataViewModel: Identifiable {
	let id: String
	let mode: Mode
#if os(watchOS)
	let name: String
#endif
	let copyright: String?
	let weakness: (any WeaknessViewModel)?
	let physiologies: PhysiologiesViewModel?

#if os(watchOS)
	init(id: String,
		 mode: Mode,
		 name: String,
		 copyright: String?,
		 weakness: (some WeaknessViewModel)?,
		 physiologies: PhysiologiesViewModel) {
		self.id = id
		self.mode = mode
		self.name = name
		self.copyright = copyright
		self.weakness = weakness
		self.physiologies = physiologies
	}
#else
	init(id: String,
		 mode: Mode,
		 copyright: String?,
		 weakness: (some WeaknessViewModel)?,
		 physiologies: PhysiologiesViewModel) {
		self.id = id
		self.mode = mode
		self.copyright = copyright
		self.weakness = weakness
		self.physiologies = physiologies
	}
#endif

	init(monster: Monster,
		 weakness: [String: Weakness],
		 options: MonsterDataViewModelBuildOptions) {
		self.id = "\(monster.id):d"
		self.mode = .lowAndHigh
#if os(watchOS)
		self.name = monster.name
#endif
		self.copyright = monster.game?.copyright
		if !options.isHidden {
			self.weakness = EffectivenessWeaknessViewModel(prefixID: id,
														   weakness: weakness,
														   options: options)
		} else {
			self.weakness = nil
		}
		self.physiologies = nil
	}

	init(monster: Monster,
		 mode: Mode,
		 physiology: Physiology,
		 multiple: Bool,
		 options: MonsterDataViewModelBuildOptions) {
		self.id = "\(monster.id):\(mode.key)"
		self.mode = mode
#if os(watchOS)
		if multiple {
			self.name = String(localized: "\(monster.name) (\(mode.label(.short)))")
		} else {
			self.name = monster.name
		}
#endif
		self.copyright = monster.game?.copyright

		if !options.isHidden {
			let weakness = NumberWeaknessViewModel(prefixID: id,
												   physiology: physiology,
												   options: options)
			self.weakness = weakness
		} else {
			self.weakness = nil
		}

		self.physiologies = PhysiologiesViewModel(rawValue: physiology)
	}
}

extension MonsterDataViewModel: Equatable {
	static func ==(lhs: MonsterDataViewModel, rhs: MonsterDataViewModel) -> Bool {
		guard lhs.id == rhs.id else { return false }

		switch (lhs.weakness, rhs.weakness) {
		case let (lw as EffectivenessWeaknessViewModel, rw as EffectivenessWeaknessViewModel):
			return lw == rw
		case let (lw as NumberWeaknessViewModel, rw as NumberWeaknessViewModel):
			return lw == rw
		default:
			return false
		}
	}
}

extension MonsterDataViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

enum MonsterDataViewModelFactory {
	static func create(monster: Monster,
					   weakness: [String: Weakness],
					   options: MonsterDataViewModelBuildOptions) -> [MonsterDataViewModel] {
		[
			MonsterDataViewModel(monster: monster,
								 weakness: weakness,
								 options: options)
		]
	}

	static func create(monster: Monster,
					   physiology physiologies: Physiologies,
					   options: MonsterDataViewModelBuildOptions)  -> [MonsterDataViewModel] {
		let multipleMode: Bool = physiologies.modes.count > 1
		return physiologies.modes.map { mode in
			MonsterDataViewModel(monster: monster,
								 mode: mode.mode,
								 physiology: mode,
								 multiple: multipleMode,
								 options: options)
		}
	}
}
