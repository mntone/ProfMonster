import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ViewModelCache<MonsterViewModel>, ObservableObject, Identifiable {
	let id: String

	@Published
	private(set) var name: String?

	@Published
	private(set) var monsters: [MonsterViewModel] = []

	init(id: String) {
		self.id = id
		super.init()
	}

	convenience init(config: MHConfigTitle) {
		self.init(id: config.id)
		updateName(config)
	}

	func loadIfNeeded() {
		guard monsters.isEmpty else {
			return
		}

		loadGameData()
	}

	private func loadGameData() {
		guard let client = MAApp.resolver.resolve(MHDataSource.self) else {
			fatalError()
		}

		client.getGame(of: id)
#if DEBUG
			.handleEvents(receiveCompletion: { completion in
				if case let .failure(error) = completion {
					debugPrint(error)
				}
			})
#endif
			.map { game in
				game.monsters.map(self.getOrCreate(id:))
			}
			.replaceError(with: [])
			.receive(on: DispatchQueue.main)
			.assign(to: &$monsters)
	}

	func updateName(_ game: MHConfigTitle) {
		let preferredLang = LanguageUtil.getPreferredLanguageKey(Array(game.names.keys))
		self.name = game.names[preferredLang]!
	}

	func getOrCreate(id monsterId: String) -> MonsterViewModel {
		getOrCreate(id: monsterId) {
			MonsterViewModel(monsterId, of: id)
		}
	}
}

// MARK: - Equatable

extension GameViewModel: Equatable {
	static func == (lhs: GameViewModel, rhs: GameViewModel) -> Bool {
		lhs.id == rhs.id
	}
}

// MARK: - Hashable

extension GameViewModel: Hashable {
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
