import Foundation
import SwiftUI

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
enum RouteHelper {
	private static let decoder = JSONDecoder()
	private static var encoder = JSONEncoder()

	static func decode(pathData: Data?) -> NavigationPath? {
		guard let pathData = pathData else {
			return nil
		}

		do {
			let representation = try decoder.decode(
				NavigationPath.CodableRepresentation.self,
				from: pathData)
			return NavigationPath(representation)
		} catch {
			return nil
		}
	}

	static func encode(path: NavigationPath) -> Data? {
		guard let representation = path.codable else {
			fatalError()
		}

		return try! encoder.encode(representation)
	}
}
