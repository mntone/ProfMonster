import Combine
import Foundation

public protocol LanguageService {
	func getMonsterName(_ id: String) -> AnyPublisher<String?, Never>
}

public struct PassthroughtLanguageService: LanguageService {
	public init() {
	}

	public func getMonsterName(_ id: String) -> AnyPublisher<String?, Never> {
		Just(id).eraseToAnyPublisher()
	}
}
