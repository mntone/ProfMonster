import Foundation
import MonsterAnalyzerCore

enum RouteHelper {
	private static func decode(from pathString: String?) -> [MARoute]? {
		guard let pathString else {
			return nil
		}

		let pathComponents = pathString.split(separator: "/")
		guard let gameID = pathComponents.first.map(String.init) else {
			return nil
		}

		let route = [.game(id: gameID)] + pathComponents.dropFirst().map { pathComponent in
			// In the future, navigate the id of other type to use prefix.
			//let i0 = pathComponent.startIndex
			//let i2 = pathComponent.index(i0, offsetBy: 2)
			//switch pathComponent[i0..<i2] {
			//case "w:":
			//default:
			return MARoute.monster(id: String(pathComponent))
			//}
		}
		return route
	}

	static func encode(path: [MARoute]) -> String? {
		guard let rootPath = path.first,
			  case let .game(rootGameID) = rootPath
		else {
			return nil
		}

		let pathString = "/\(rootGameID)/" + path.dropFirst().map { route in
			switch route {
			case .game:
				fatalError()
			case let .monster(id):
				return id
			}
		}.joined(separator: "/")
		return pathString
	}

	static func load(from pathString: String?) async -> [MARoute] {
		let notCrashed = await !MAApp.crashed
		await MAApp.resetCrashed()
		guard notCrashed,
			  let route = Self.decode(from: pathString) else {
			return []
		}

		guard case let .game(rootGameID) = route[0],
			  let app = await MAApp.resolver.resolve(App.self) else {
			fatalError()
		}

		// Prefetch game data from caches or network.
		// So, returns nil if an error occurs.
		guard let game = await app.prefetch(of: rootGameID) else {
			return []
		}

		var filteredRoute: [MARoute] = [route[0]]
		for path in route.dropFirst() {
			var stopping = false
			switch path {
			case .game:
				fatalError()
			case let .monster(id):
				guard await game.prefetch(of: id) != nil else {
					stopping = true
					break
				}
				filteredRoute.append(path)
			}
			if stopping {
				break
			}
		}
		return filteredRoute
	}
}
