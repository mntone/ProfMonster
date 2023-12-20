import Foundation
import SwiftUI

enum MARoute: Hashable {
	case game(gameID: String)
	case monster(gameID: String, monsterID: String)

	init(rawValue value: String) {
		let i0 = value.startIndex
		let i2 = value.index(i0, offsetBy: 2)
		switch value[i0..<i2] {
		case "g:":
			let gameID = String(value[i2...])
			self = .game(gameID: gameID)
		case "m:":
			let ids = value[i2...].split(separator: ":", maxSplits: 1).map(String.init)
			self = .monster(gameID: ids[0], monsterID: ids[1])
		default:
			fatalError()
		}
	}
}
