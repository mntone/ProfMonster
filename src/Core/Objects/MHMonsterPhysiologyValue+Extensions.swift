import Foundation

public extension MHMonsterPhysiologyValue {
	func getValues(for attacks: [Attack]) -> [Int8] {
		attacks.map { attack in
			self[keyPath: attack.keyPathForMonsterPhysiologyValue]
		}
	}
}
