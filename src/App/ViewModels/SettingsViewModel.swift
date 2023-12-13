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
	private let storage: Storage
	
	@Published
	var storageSize: String?
	
	init(rootViewModel: HomeViewModel,
		 storage: Storage) {
		self.rootViewModel = rootViewModel
		self.storage = storage
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
		rootViewModel.clear()

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
