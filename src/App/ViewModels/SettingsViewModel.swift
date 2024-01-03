import Combine
import Foundation
import MonsterAnalyzerCore
import SwiftUI

final class SettingsViewModel: ObservableObject {
	private let formatter = {
		var formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useBytes, .useKB, .useMB]
		formatter.countStyle = .file
		return formatter
	}()

	private let rootViewModel: HomeViewModel
	private let settings: MonsterAnalyzerCore.Settings
	private let storage: Storage

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

	init(rootViewModel: HomeViewModel,
		 storage: Storage) {
		guard let app = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self) else {
			fatalError()
		}
		self.rootViewModel = rootViewModel
		self.settings = app.settings
		self.storage = storage
#if !os(watchOS)
		self.includesFavoriteGroupInSearchResult = app.settings.includesFavoriteGroupInSearchResult
#endif
#if os(iOS)
		self.showTitle = app.settings.showTitle
#endif
		self.elementDisplay = app.settings.elementDisplay
		self.mergeParts = app.settings.mergeParts

		let scheduler = DispatchQueue.main
#if !os(watchOS)
		settings.$includesFavoriteGroupInSearchResult.dropFirst().receive(on: scheduler).assign(to: &$includesFavoriteGroupInSearchResult)
#endif
#if os(iOS)
		settings.$showTitle.dropFirst().receive(on: scheduler).assign(to: &$showTitle)
#endif
		settings.$elementDisplay.dropFirst().receive(on: scheduler).assign(to: &$elementDisplay)
		settings.$mergeParts.dropFirst().receive(on: scheduler).assign(to: &$mergeParts)
	}

	convenience init(rootViewModel: HomeViewModel) {
		guard let storage = MAApp.resolver.resolve(Storage.self) else {
			fatalError()
		}
		self.init(rootViewModel: rootViewModel, storage: storage)
	}

	func resetAllCaches() {
		Task(priority: .utility) {
			storage.resetAll()
		}
		rootViewModel.resetData()

		storageSize = nil
		Task(operation: updateStorageSize)
	}

	@Sendable
	func updateStorageSize() async {
		let storageSize = await Task(priority: .utility) {
			let size = storage.size
			return formatter.string(fromByteCount: Int64(clamping: size))
		}.value
		DispatchQueue.main.async {
			withAnimation(.easeInOut(duration: 0.333)) {
				self.storageSize = storageSize
			}
		}
	}
}
