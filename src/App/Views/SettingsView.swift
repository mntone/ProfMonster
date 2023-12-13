import MonsterAnalyzerCore
import SwiftUI

struct RemoveCacheButton: View {
	private let viewModel: SettingsViewModel

	@State
	private var isConfirm: Bool = false
	
	init(_ viewModel: SettingsViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		Button("settings.removeCache.action") {
			isConfirm = true
		}
		.foregroundColor(.blue)
		.alert("settings.removeCache.title", isPresented: $isConfirm) {
			Button(role: .destructive) {
				viewModel.resetAllCaches()
			} label: {
				Text("settings.removeCache.action")
			}

			Button("settings.removeCache.cancel", role: .cancel) {
				isConfirm = false
			}
		} message: {
			Text("settings.removeCache.message")
		}
	}
}

struct SettingsView: View {
#if os(iOS)
	@Environment(\.settingsAction)
	private var settingsAction
#endif

	@ObservedObject
	private var viewModel: SettingsViewModel

	init(_ viewModel: SettingsViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List {
			Section {
				RemoveCacheButton(viewModel)
			} footer: {
				if let storageSize = viewModel.storageSize {
					Text("settings.cachesize(\(storageSize))")
				}
			}
		}
#if os(iOS)
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("settings.close", role: .cancel) {
					settingsAction?.dismiss()
				}
			}
		}
#endif
		.navigationTitle("settings.title")
#if !os(macOS)
		.navigationBarTitleDisplayMode(.large)
#endif
		.task {
			await viewModel.updateStorageSize()
		}
	}
}

struct SettingsContainerView: View {
	private let viewModel: SettingsViewModel
	
	init(_ viewModel: SettingsViewModel) {
		self.viewModel = viewModel
	}
	
	var body: some View {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			NavigationStack {
				SettingsView(viewModel)
			}
		} else {
			NavigationView {
				SettingsView(viewModel)
			}
#if !os(macOS)
			.navigationViewStyle(.stack)
#endif
		}
	}
}
