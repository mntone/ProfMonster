import MonsterAnalyzerCore

struct MonsterDataViewModel: Identifiable {
	let id: String
	let mode: Mode
	let copyright: String?
	let weakness: (any WeaknessViewModel)?
	let physiologies: PhysiologiesViewModel?

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

	init(prefixID: String,
		 copyright: String?,
		 displayMode: WeaknessDisplayMode,
		 weaknesses: [String: Weakness]) {
		self.id = "\(prefixID):default"
		self.mode = .lowAndHigh
		self.copyright = copyright
		if displayMode != .none {
			self.weakness = EffectivenessWeaknessViewModel(prefixID: id,
														   displayMode: displayMode,
														   rawValue: weaknesses)
		} else {
			self.weakness = nil
		}
		self.physiologies = nil
	}

	init(prefixID: String,
		 mode: Mode,
		 copyright: String?,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiology) {
		self.id = "\(prefixID):\(mode)"
		self.mode = mode
		self.copyright = copyright
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
	static func create(_ id: String,
					   copyright: String?,
					   displayMode: WeaknessDisplayMode,
					   weaknesses: [String: Weakness]) -> [MonsterDataViewModel] {
		[
			MonsterDataViewModel(prefixID: id,
								 copyright: copyright,
								 displayMode: displayMode,
								 weaknesses: weaknesses)
		]
	}

	static func create(_ id: String,
					   copyright: String?,
					   displayMode: WeaknessDisplayMode,
					   rawValue: Physiologies)  -> [MonsterDataViewModel] {
		rawValue.modes.map { mode in
			MonsterDataViewModel(prefixID: id,
								 mode: mode.mode,
								 copyright: copyright,
								 displayMode: displayMode,
								 rawValue: mode)
		}
	}
}
