import Combine
import Foundation

public protocol LanguageService {
	func getMonster(_ id: String) -> AnyPublisher<MHLocalizationMonster?, Never>
}

public struct PassthroughtLanguageService: LanguageService {
	public init() {
	}

	public func getMonster(_ id: String) -> AnyPublisher<MHLocalizationMonster?, Never> {
		Just(MHLocalizationMonster(id: id, name: id)).eraseToAnyPublisher()
	}
}
