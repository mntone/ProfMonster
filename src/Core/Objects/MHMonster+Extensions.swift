import Foundation

public extension MHMonster {
	func getAverage(of attack: Attack) -> Float {
		let keyPath = attack.keyPathForMonsterPhysiologyValue
		let flatPhys = physiologies.flatMap { p in p.values }
		return Float(flatPhys.reduce(0) { cur, next in
			cur + Int(next[keyPath: keyPath])
		}) / Float(flatPhys.count)
	}

	func getAverages(of attacks: [Attack]) -> [Float] {
		attacks.map(getAverage(of:))
	}
}
