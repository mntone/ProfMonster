import MonsterAnalyzerCore

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
		 displayMode: WeaknessDisplayMode,
		 weaknesses: [String: Weakness]) {
		self.id = "\(monster.id):default"
		self.mode = .lowAndHigh
#if os(watchOS)
		self.name = monster.name
#endif
		self.copyright = monster.game?.copyright
		if displayMode != .none {
			self.weakness = EffectivenessWeaknessViewModel(prefixID: id,
														   displayMode: displayMode,
														   rawValue: weaknesses)
		} else {
			self.weakness = nil
		}
		self.physiologies = nil
	}

	init(monster: Monster,
		 mode: Mode,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiology,
		 multiple: Bool) {
		self.id = "\(monster.id):\(mode)"
		self.mode = mode
#if os(watchOS)
		if multiple {
			self.name = String(localized: "\(monster.name) (\(mode.label(.short)))")
		} else {
			self.name = monster.name
		}
#endif
		self.copyright = monster.game?.copyright
		if displayMode != .none {
			let weakness = NumberWeaknessViewModel(prefixID: id,
												   displayMode: displayMode,
												   rawValue: rawValue)
			if displayMode == .sign {
				if let defaultWeakness = weakness.sections.first(where: { $0.isDefault }) {
					self.weakness = NumberWeaknessViewModel(id: weakness.id,
															displayMode: displayMode,
															sections: weakness.sections.filter {
						$0.isDefault || !NumberWeaknessSectionViewModel.compareEffectiveness(lhs: $0, rhs: defaultWeakness)
					})
				} else {
					self.weakness = weakness
				}
			} else {
				self.weakness = weakness
			}
		} else {
			self.weakness = nil
		}
		self.physiologies = PhysiologiesViewModel(rawValue: rawValue)
	}
}

extension MonsterDataViewModel: Equatable {
	static func ==(lhs: MonsterDataViewModel, rhs: MonsterDataViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

extension MonsterDataViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

enum MonsterDataViewModelFactory {
	static func create(monster: Monster,
					   displayMode: WeaknessDisplayMode,
					   weaknesses: [String: Weakness]) -> [MonsterDataViewModel] {
		[
			MonsterDataViewModel(monster: monster,
								 displayMode: displayMode,
								 weaknesses: weaknesses)
		]
	}

	static func create(monster: Monster,
					   displayMode: WeaknessDisplayMode,
					   rawValue: Physiologies)  -> [MonsterDataViewModel] {
		let multipleMode: Bool = rawValue.modes.count > 1
		return rawValue.modes.map { mode in
			MonsterDataViewModel(monster: monster,
								 mode: mode.mode,
								 displayMode: displayMode,
								 rawValue: mode,
								 multiple: multipleMode)
		}
	}
}
