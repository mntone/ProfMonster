import Foundation
import MonsterAnalyzerCore

struct MonsterDataViewModel {
	let id: String
	let copyright: String?
	let weakness: WeaknessViewModel?
	let physiologies: PhysiologiesViewModel

	init(id: String,
		 copyright: String?,
		 weakness: WeaknessViewModel?,
		 physiologies: PhysiologiesViewModel) {
		self.id = id
		self.copyright = copyright
		self.weakness = weakness
		self.physiologies = physiologies
	}

	init(_ id: String,
		 copyright: String?,
		 displayMode: WeaknessDisplayMode,
		 rawValue: Physiologies) {
		self.id = id
		self.copyright = copyright
		if displayMode != .none {
			self.weakness = WeaknessViewModel(id, displayMode: displayMode, rawValue: rawValue)
		} else {
			self.weakness = nil
		}
		self.physiologies = PhysiologiesViewModel(rawValue: rawValue)
	}
}
