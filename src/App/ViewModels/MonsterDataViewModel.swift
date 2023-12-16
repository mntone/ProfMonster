import Foundation
import MonsterAnalyzerCore

struct MonsterDataViewModel {
	let weakness: WeaknessViewModel
	let physiologies: PhysiologiesViewModel

	init(weakness: WeaknessViewModel, physiologies: PhysiologiesViewModel) {
		self.weakness = weakness
		self.physiologies = physiologies
	}

	init(rawValue: Physiologies) {
		self.weakness = WeaknessViewModel(rawValue: rawValue)
		self.physiologies = PhysiologiesViewModel(rawValue: rawValue)
	}
}
