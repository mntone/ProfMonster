import Foundation
import MonsterAnalyzerCore

struct MonsterDataViewModel {
	let id: String
	let weakness: WeaknessViewModel
	let physiologies: PhysiologiesViewModel

	init(id: String,
		 weakness: WeaknessViewModel,
		 physiologies: PhysiologiesViewModel) {
		self.id = id
		self.weakness = weakness
		self.physiologies = physiologies
	}

	init(_ id: String, rawValue: Physiologies) {
		self.id = id
		self.weakness = WeaknessViewModel(id, rawValue: rawValue)
		self.physiologies = PhysiologiesViewModel(rawValue: rawValue)
	}
}
