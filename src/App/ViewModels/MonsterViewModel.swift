import Combine
import Foundation
import MonsterAnalyzerCore

final class MonsterViewModel: ObservableObject, Identifiable {
	let id: String
	let gameId: String

	@Published
	private(set) var name: String?

	@Published
	private(set) var state: ViewModelStateAnd<MHMonster> = .ready

	init(_ id: String, of gameId: String) {
		self.id = id
		self.gameId = gameId

		loadMonsterName()
	}

	private func loadMonsterName() {
		guard let langsvc = MAApp.resolver.resolve(LanguageService.self, argument: gameId) else {
			// TODO: Logger
			fatalError()
		}
		langsvc.getMonsterName(id)
			.receive(on: DispatchQueue.main)
			.assign(to: &$name)
	}

	func loadIfNeeded() {
		guard case .ready = state else {
			return
		}
		state = .loading

		guard let client = MAApp.resolver.resolve(MHDataSource.self) else {
			fatalError()
		}

		client.getMonster(of: id, for: gameId)
#if DEBUG
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					debugPrint(error)
				}
			})
#endif
			.map { monster in
				ViewModelStateAnd<MHMonster>.complete(data: monster)
			}
			.catch { error in
				let state: ViewModelStateAnd<MHMonster>
				switch error {
				case let error as URLError where error.code == URLError.networkConnectionLost || error.code == URLError.notConnectedToInternet:
					state = .failure(date: .now, error: .noConnection)
					break
				case let error as URLError where error.code == URLError.timedOut:
					state = .failure(date: .now, error: .timeout)
					break
				case let error as URLError where error.code == URLError.fileDoesNotExist:
					state = .failure(date: .now, error: .notFound)
					break
				default:
					state = .failure(date: .now, error: .other(error))
					break
				}
				return Just(state)
			}
			.receive(on: DispatchQueue.main)
			.assign(to: &$state)
	}
}
