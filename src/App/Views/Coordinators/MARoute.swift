import Foundation

enum MARoute: Hashable {
	case game(id: String)
	case monster(id: String)

	init(rawValue value: String) {
		let i0 = value.startIndex
		let i2 = value.index(i0, offsetBy: 2)
		switch value[i0..<i2] {
		case "g:":
			let id = String(value[i2...])
			self = .game(id: id)
		case "m:":
			let id = String(value[i2...])
			self = .monster(id: id)
		default:
			fatalError()
		}
	}
}
