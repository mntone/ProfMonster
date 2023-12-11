import Foundation
import SwiftUI

enum RouteHelper {
	private static let decoder = JSONDecoder()
	private static let encoder = JSONEncoder()

	static func decode(pathData: Data?) -> [MARoute] {
		guard let pathData = pathData else {
			return []
		}

		do {
			let path = try decoder.decode(
				[MARoute].self,
				from: pathData)
			return path
		} catch {
			return []
		}
	}

	static func encode(path: [MARoute]) -> Data? {
		return try! encoder.encode(path)
	}
}
