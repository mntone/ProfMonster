import MonsterAnalyzerCore

struct MonsterDataViewModel {
	let id: String
	let copyright: String?
	let weakness: (any WeaknessViewModel)?
	let physiologies: PhysiologiesViewModel?

	init(id: String,
		 copyright: String?,
		 weakness: (some WeaknessViewModel)?,
		 physiologies: PhysiologiesViewModel) {
		self.id = id
		self.copyright = copyright
		self.weakness = weakness
		self.physiologies = physiologies
	}

	init(_ id: String,
		 copyright: String?,
		 displayMode: WeaknessDisplayMode,
		 weaknesses: [String: Weakness]) {
		self.id = id
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

	init(_ id: String,
		 copyright: String?,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiologies) {
		self.id = id
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
