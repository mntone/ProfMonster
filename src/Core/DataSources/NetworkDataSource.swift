import Foundation

public struct NetworkDataSourceOptions {
	public let retryCount: Int

	init(retryCount: Int = 1) {
		self.retryCount = retryCount
	}

	public static let `default` = NetworkDataSourceOptions()
}

final class NetworkDataSource {
	private let source: URL
	private let logger: Logger
	private let decoder: JSONDecoder
	private let session: URLSession
	private let options: NetworkDataSourceOptions

	init(source: URL, logger: Logger, session: URLSession, options: NetworkDataSourceOptions = .default) {
		self.source = source
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		self.logger = logger
		self.decoder = decoder
		self.session = session
		self.options = options
	}

	convenience init(source: URL, logger: Logger, options: NetworkDataSourceOptions = .default) {
		let conf = URLSessionConfiguration.ephemeral
		conf.httpAdditionalHeaders = [
			"Accept": "application/json",
		]
		conf.httpShouldSetCookies = false
		conf.waitsForConnectivity = false
		let session = URLSession(configuration: conf)
		self.init(source: source, logger: logger, session: session)
	}

	private func getItem<Item: Decodable>(of url: URL, type: Item.Type) async throws -> Item {
		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
		request.assumesHTTP3Capable = true
		request.networkServiceType = .responsiveData
		return try await getItem(ofRequest: request, type: type, count: options.retryCount)
	}

	private func getItem<Item: Decodable>(ofRequest urlRequest: URLRequest, type: Item.Type, count: Int = 0) async throws -> Item {
		do {
			let (data, response) = try await session.data(for: urlRequest)
			try handle(response: response)
			return try decoder.decode(type, from: data)
		} catch {
			if count != 0 {
				let retry: Bool
				switch error {
				case let urlError as URLError:
					switch urlError.code {
					case .timedOut, .networkConnectionLost, .notConnectedToInternet:
						retry = true
					default:
						retry = false
					}
				case DecodingError.dataCorrupted:
					retry = true
				default:
					retry = false
				}

				if retry {
					return try await getItem(ofRequest: urlRequest, type: type, count: options.retryCount - 1)
				}
			}
			throw error
		}
	}

	private func handle(response: URLResponse) throws {
		guard let response = response as? HTTPURLResponse,
			  (200...299).contains(response.statusCode) else {
			throw URLError(.badServerResponse)
		}

		//guard response.mimeType == "application/json" else {
		//	throw URLError(.badServerResponse)
		//}
	}
}

// MARK: - DataSource

extension NetworkDataSource: DataSource {
	func getConfig() async throws -> MHConfig {
		guard let url = URL(string: "config.json", relativeTo: source) else {
			logger.fault("Failed to build URL.")
		}
		return try await getItem(of: url, type: MHConfig.self)
	}

	func getGame(of titleId: String) async throws -> MHGame {
		guard let url = URL(string: "\(titleId)/index.json", relativeTo: source) else {
			logger.fault("Failed to build URL of the game (id: \(titleId)).")
		}
		return try await getItem(of: url, type: MHGame.self)
	}

	func getLocalization(of key: String) async throws -> MHLocalization {
		guard let url = URL(string: "localization/\(key).json", relativeTo: source) else {
			logger.fault("Failed to build URL.")
		}
		return try await getItem(of: url, type: MHLocalization.self)
	}

	func getMonster(of id: String, for titleId: String) async throws -> MHMonster {
		guard let url = URL(string: "\(titleId)/monsters/\(id).json", relativeTo: source) else {
			logger.fault("Failed to build URL of the monster (id: \(titleId):\(id).")
		}
		return try await getItem(of: url, type: MHMonster.self)
	}
}
