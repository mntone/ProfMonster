import Combine
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
	private let decoder: JSONDecoder
	private let session: URLSession
	private let options: NetworkDataSourceOptions

	init(source: URL, session: URLSession, options: NetworkDataSourceOptions = .default) {
		self.source = source
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		self.decoder = decoder
		self.session = session
		self.options = options
	}

	convenience init(source: URL, options: NetworkDataSourceOptions = .default) {
		let conf = URLSessionConfiguration.ephemeral
		conf.httpAdditionalHeaders = [
			"Accept": "application/json",
		]
		let session = URLSession(configuration: conf)
		self.init(source: source, session: session)
	}

	private func getData(of url: URL) -> Publishers.RetryIf<Publishers.TryMap<URLSession.DataTaskPublisher, Data>> {
		var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
		request.assumesHTTP3Capable = true
		request.networkServiceType = .responsiveData
		return session.dataTaskPublisher(for: request).tryMap { data, response in
			guard let response = response as? HTTPURLResponse,
				  (200...299).contains(response.statusCode) else {
				throw URLError(.badServerResponse)
			}

			//guard response.mimeType == "application/json" else {
			//	throw URLError(.badServerResponse)
			//}

			return data
		}.retry(times: options.retryCount) { error in
			if case let urlError as URLError = error {
				switch urlError.code {
				case .timedOut, .networkConnectionLost, .notConnectedToInternet:
					return true
				default:
					break
				}
			}
			return false
		}
	}

	private func getData<Item>(of url: URL, type: Item.Type) -> Publishers.Decode<Publishers.RetryIf<Publishers.TryMap<URLSession.DataTaskPublisher, Data>>, Item, JSONDecoder> {
		getData(of: url).decode(type: type, decoder: decoder)
	}
}

// MARK: - MHDataOffer
extension NetworkDataSource: DataSource {
	func getConfig() -> AnyPublisher<MHConfig, Error> {
		guard let url = URL(string: "config.json", relativeTo: source) else {
			fatalError()
		}

		return getData(of: url, type: MHConfig.self)
			.eraseToAnyPublisher()
	}

	func getGame(of titleId: String) -> AnyPublisher<MHGame, Error> {
		guard let url = URL(string: "\(titleId)/index.json", relativeTo: source) else {
			fatalError()
		}

		return getData(of: url, type: MHGame.self)
			.eraseToAnyPublisher()
	}

	func getLocalization(of key: String, for titleId: String) -> AnyPublisher<MHLocalization, Error> {
		guard let url = URL(string: "\(titleId)/localization/\(key).json", relativeTo: source) else {
			fatalError()
		}

		return getData(of: url, type: MHLocalization.self)
			.eraseToAnyPublisher()
	}

	func getMonster(of id: String, for titleId: String) -> AnyPublisher<MHMonster, Error> {
		guard let url = URL(string: "\(titleId)/monsters/\(id).json", relativeTo: source) else {
			fatalError()
		}

		return getData(of: url, type: MHMonster.self)
			.eraseToAnyPublisher()
	}
}
