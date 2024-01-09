import Combine
import Foundation
import MonsterAnalyzerCore

final class SettingsViewModel: ObservableObject {
	private let formatter = {
		var formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useBytes, .useKB, .useMB]
		formatter.countStyle = .file
		return formatter
	}()

	private let app: MonsterAnalyzerCore.App
	private let settings: MonsterAnalyzerCore.Settings

	@Published
	var storageSize: String?

#if os(iOS)
	@Published
	var showTitle: Bool {
		didSet {
			settings.showTitle = showTitle
		}
	}
#endif

#if os(watchOS)
	@Published
	var sort: Sort {
		didSet {
			settings.sort = sort
		}
	}
#endif

#if !os(macOS)
	@Published
	var trailingSwipeAction: SwipeAction {
		didSet {
			settings.trailingSwipeAction = trailingSwipeAction
		}
	}
#endif

#if !os(watchOS)
	@Published
	var includesFavoriteGroupInSearchResult: Bool {
		didSet {
			settings.includesFavoriteGroupInSearchResult = includesFavoriteGroupInSearchResult
		}
	}
#endif

	@Published
	var elementDisplay: WeaknessDisplayMode {
		didSet {
			settings.elementDisplay = elementDisplay
		}
	}

	@Published
	var mergeParts: Bool {
		didSet {
			settings.mergeParts = mergeParts
		}
	}

	@Published
	var showInternalInformation: Bool {
		didSet {
			settings.showInternalInformation = showInternalInformation
		}
	}

	@Published
	var test: String {
		didSet {
			settings.test = test
		}
	}

	init() {
		guard let app = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self) else {
			fatalError()
		}
		self.app = app
		self.settings = app.settings
#if os(watchOS)
		self.sort = app.settings.sort
#endif
#if !os(macOS)
		self.trailingSwipeAction = app.settings.trailingSwipeAction
#endif
#if !os(watchOS)
		self.includesFavoriteGroupInSearchResult = app.settings.includesFavoriteGroupInSearchResult
#endif
#if os(iOS)
		self.showTitle = app.settings.showTitle
#endif
		self.elementDisplay = app.settings.elementDisplay
		self.mergeParts = app.settings.mergeParts
		self.showInternalInformation = app.settings.showInternalInformation
		self.test = app.settings.test

		let scheduler = DispatchQueue.main
#if os(watchOS)
		settings.$sort.dropFirst().receive(on: scheduler).assign(to: &$sort)
#endif
#if !os(macOS)
		settings.$trailingSwipeAction.dropFirst().receive(on: scheduler).assign(to: &$trailingSwipeAction)
#endif
#if !os(watchOS)
		settings.$includesFavoriteGroupInSearchResult.dropFirst().receive(on: scheduler).assign(to: &$includesFavoriteGroupInSearchResult)
#endif
#if os(iOS)
		settings.$showTitle.dropFirst().receive(on: scheduler).assign(to: &$showTitle)
#endif
		settings.$elementDisplay.dropFirst().receive(on: scheduler).assign(to: &$elementDisplay)
		settings.$mergeParts.dropFirst().receive(on: scheduler).assign(to: &$mergeParts)
		settings.$showInternalInformation.dropFirst().receive(on: scheduler).assign(to: &$showInternalInformation)
		settings.$test.dropFirst().receive(on: scheduler).assign(to: &$test)
	}

	func resetAllCaches() {
		storageSize = nil

		Task(priority: .utility) {
			await app.resetAllData().value
			await updateStorageSize()
		}
	}

	func updateStorageSize() async {
		let sizeString = await app.getCacheSize().map { size in
			formatter.string(fromByteCount: Int64(clamping: size))
		}
		DispatchQueue.main.async {
			self.storageSize = sizeString
		}
	}
}
