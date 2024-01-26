import Combine
import Foundation
import MonsterAnalyzerCore

final class SettingsViewModel: ObservableObject {
	private let app: MonsterAnalyzerCore.App
	private let settings: MonsterAnalyzerCore.Settings

	private var cancellable: AnyCancellable?

#if os(iOS)
	private let mockData: Physiology

	@Published
	private(set) var elementAttackPreview: NumberWeaknessViewModel?
#endif

#if os(watchOS)
	@Published
	var sort: Sort {
		didSet {
			settings.sort = sort
		}
	}

	@Published
	var groupOption: GroupOption {
		didSet {
			settings.groupOption = groupOption
		}
	}
#endif

	@Published
	var trailingSwipeAction: SwipeAction {
		didSet {
			settings.trailingSwipeAction = trailingSwipeAction
		}
	}

#if !os(watchOS)
	@Published
	var includesFavoriteGroupInSearchResult: Bool {
		didSet {
			settings.includesFavoriteGroupInSearchResult = includesFavoriteGroupInSearchResult
		}
	}
#endif

	@Published
	var showPhysicalAttack: Bool {
		didSet {
			settings.showPhysicalAttack = showPhysicalAttack
		}
	}

	@Published
	var elementAttack: ElementWeaknessDisplayMode {
		didSet {
#if os(iOS)
			updateElementAttack()
#endif
			settings.elementAttack = elementAttack
		}
	}

	@Published
	var mergeParts: Bool {
		didSet {
			settings.mergeParts = mergeParts
		}
	}

#if os(iOS)
	@Published
	var keyboardDismissMode: KeyboardDismissMode {
		didSet {
			settings.keyboardDismissMode = keyboardDismissMode
		}
	}
#endif

	init() {
		guard let app = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self) else {
			fatalError()
		}
		self.app = app
		self.settings = app.settings
#if os(iOS)
		self.mockData = MockData.physiology(.guluQoo)!.modes[0]
#endif

#if os(watchOS)
		self.sort = app.settings.sort
		self.groupOption = app.settings.groupOption
#endif
		self.trailingSwipeAction = app.settings.trailingSwipeAction
#if !os(watchOS)
		self.includesFavoriteGroupInSearchResult = app.settings.includesFavoriteGroupInSearchResult
#endif
		self.showPhysicalAttack = app.settings.showPhysicalAttack
		self.elementAttack = app.settings.elementAttack
		self.mergeParts = app.settings.mergeParts
#if os(iOS)
		self.keyboardDismissMode = app.settings.keyboardDismissMode
#endif

		let scheduler = DispatchQueue.main
#if os(watchOS)
		settings.$sort.dropFirst().receive(on: scheduler).assign(to: &$sort)
		settings.$groupOption.dropFirst().receive(on: scheduler).assign(to: &$groupOption)
#endif
		settings.$trailingSwipeAction.dropFirst().receive(on: scheduler).assign(to: &$trailingSwipeAction)
#if !os(watchOS)
		settings.$includesFavoriteGroupInSearchResult.dropFirst().receive(on: scheduler).assign(to: &$includesFavoriteGroupInSearchResult)
#endif
		settings.$showPhysicalAttack.dropFirst().receive(on: scheduler).assign(to: &$showPhysicalAttack)
		settings.$elementAttack.dropFirst().receive(on: scheduler).assign(to: &$elementAttack)
		settings.$mergeParts.dropFirst().receive(on: scheduler).assign(to: &$mergeParts)
#if os(iOS)
		settings.$keyboardDismissMode.dropFirst().receive(on: scheduler).assign(to: &$keyboardDismissMode)
#endif

		// App should reload to change some settings.
		cancellable = $mergeParts
			.debounce(for: 2.0, scheduler: DispatchQueue.global(qos: .utility))
			.removeDuplicates { oldMergeParts, newMergeParts in
				return oldMergeParts == newMergeParts
			}
			.dropFirst()
			.sink { _ in
				app.resetMemoryData()
			}

#if os(iOS)
		updateElementAttack()
#endif
	}

	// MARK: - Element Attack Preview
	
#if os(iOS)
	private func updateElementAttack() {
		if elementAttack != .none {
			let options = MonsterDataViewModelBuildOptions(physical: false, element: elementAttack)
			let viewModel = NumberWeaknessViewModel(prefixID: "settings", physiology: mockData, options: options)
			elementAttackPreview = viewModel
		} else {
			elementAttackPreview = nil
		}
	}
#endif
}
