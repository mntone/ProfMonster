import Foundation
import MonsterAnalyzerCore

final class DataSettingsViewModel: ObservableObject {
	private let formatter = {
		var formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useBytes, .useKB, .useMB]
		formatter.countStyle = .file
		return formatter
	}()

	private let urlRegex = try! NSRegularExpression(pattern: "^https://[\\w!\\?/\\+\\-_~=;\\.,\\*&@#\\$%\\(\\)'\\[\\]]+$",
													options: .useUnixLineSeparators)

	private var app: MonsterAnalyzerCore.App

	var currentURLString: String {
		app.sourceURL.absoluteString
	}

#if os(watchOS)
	@Published
	var isSourceURLChanged: Bool = false
#endif

	@Published
	var enableSaveButton: Bool = false

	@Published
	var sourceURLString: String {
		didSet {
			let isChanged = app.isUserSource
				? currentURLString != sourceURLString
				: !sourceURLString.isEmpty && currentURLString != sourceURLString
#if os(watchOS)
			isSourceURLChanged = isChanged
#endif
			enableSaveButton = isChanged && urlRegex.firstMatch(in: sourceURLString, range: NSRange(0..<sourceURLString.count)) != nil
		}
	}

	@Published
	var storageSize: String?

	init() {
		guard let app = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self) else {
			fatalError()
		}
		self.app = app
		self.sourceURLString = Self.getSourceURLString(app)
	}

	// MARK: - Data Source

	func save() {
		app.changeSourceURL(sourceURLString)

		// Get new App context.
		if let app = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self) {
			self.app = app
		}

#if os(watchOS)
		isSourceURLChanged = false
#endif
	}

	func cancel() {
		sourceURLString = Self.getSourceURLString(app)
	}

	private static func getSourceURLString(_ app: App) -> String {
		let sourceURLString: String
		if app.isUserSource {
			sourceURLString = app.sourceURL.absoluteString
		} else {
			sourceURLString = ""
		}
		return sourceURLString
	}

	// MARK: - Caches

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

	// MARK: - Settings

	func resetAllSettings() {
		app.resetAllSettings()
	}
}
