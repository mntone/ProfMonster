import Foundation
import SwiftUI

enum MARoute: Hashable {
	case game(gameId: String)
	case monster(gameId: String, monsterId: String)

	init(rawValue value: String) {
		let i0 = value.startIndex
		let i2 = value.index(i0, offsetBy: 2)
		switch value[i0..<i2] {
		case "g:":
			let gameId = String(value[i2...])
			self = .game(gameId: gameId)
		case "m:":
			let ids = value[i2...].split(separator: ":", maxSplits: 1).map(String.init)
			self = .monster(gameId: ids[0], monsterId: ids[1])
		default:
			fatalError()
		}
	}

	var path: String {
		switch self {
		case let .game(gameId):
			return "g:\(gameId)"
		case let .monster(gameId, monsterId):
			return "m:\(gameId):\(monsterId)"
		}
	}
}

// MARK: - Decodable

extension MARoute: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self = MARoute(rawValue: try container.decode(String.self))
	}
}

// MARK: - Encodable

extension MARoute: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(path)
	}
}

// MARK: - Array of MARoute

@available(iOS 16.0, macOS 12.0, watchOS 9.0, *)
extension Array where Element == MARoute {
	init(string: String) {
		var savedGameId: String?
		self = string.dropFirst().split(separator: "/").map { value in
			let i0 = value.startIndex
			let i2 = value.index(i0, offsetBy: 2)
			switch value[i0..<i2] {
			case "g:":
				let gameId = String(value[i2...])
				savedGameId = gameId
				return MARoute.game(gameId: gameId)
			case "m:":
				guard let savedGameId = savedGameId else {
					fatalError()
				}
				return MARoute.monster(gameId: savedGameId, monsterId: String(value[i2...]))
			default:
				fatalError()
			}
		}
	}
}
