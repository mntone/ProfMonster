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
			self.weakness = NumberWeaknessViewModel(prefixID: id,
													displayMode: displayMode,
													rawValue: rawValue)
		} else {
			self.weakness = nil
		}
		self.physiologies = PhysiologiesViewModel(rawValue: rawValue)
	}
}
