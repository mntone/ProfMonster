import Foundation
import MonsterAnalyzerCore

final class GameViewModel: ViewModelCache<MonsterViewModel>, ObservableObject, Identifiable {
	let id: String
	let textProcessor: TextProcessor

	@Published
	private(set) var name: String?

	@Published
	private(set) var monsters: [MonsterViewModel] = []
	
	@Published
	var searchText: String = ""

	init(id: String) {
		self.id = id

		guard let textProcessor = MAApp.resolver.resolve(TextProcessor.self) else {
			fatalError()
		}
		self.textProcessor = textProcessor
		
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
			.flatMap { monsters in
				self.$searchText
					.debounce(for: 0.333, scheduler: DispatchQueue.main)
					.map { text in
						if text.isEmpty {
							return monsters
						} else {
							let normalizedText = self.textProcessor.normalize(text)
							return monsters.filter { monster in
								monster.keywords.contains { keyword in
									keyword.contains(normalizedText)
								}
							}
						}
					}
			}
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
