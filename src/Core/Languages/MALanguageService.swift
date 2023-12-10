import Combine
import Foundation

public final class MALanguageService: LanguageService {
	private let dataPublisher: Publishers.Share<Publishers.FlatMap<Publishers.Map<AnyPublisher<MHLocalization, any Error>, [String : MHLocalizationMonster]>, AnyPublisher<MHGame, any Error>>>

	public init(source: MHDataSource, id: String) {
		self.dataPublisher = MALanguageService.getPreferredData(source: source, id: id)
	}

	public func getMonsterName(_ id: String) -> AnyPublisher<String?, Never> {
		dataPublisher
			.map { data in
				data[id]?.name
			}
			.replaceError(with: nil)
			.eraseToAnyPublisher()
	}

	private static func getPreferredData(source: MHDataSource, id: String) -> Publishers.Share<Publishers.FlatMap<Publishers.Map<AnyPublisher<MHLocalization, any Error>, [String : MHLocalizationMonster]>, AnyPublisher<MHGame, any Error>>> {
		return source.getGame(of: id)
			.flatMap { data in
				let preferredKey = LanguageUtil.getPreferredLanguageKey(data.localization)
				return source.getLocalization(of: preferredKey, for: id).map { data in
					data.monsters.reduce(into: [:]) { cur, next in
						cur[next.id] = next
					}
				}
			}
			.share()
	}
}
