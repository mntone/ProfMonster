import SwiftUI

struct RemoveCacheButton: View {
	let viewModel: SettingsViewModel

	@State
	private var isConfirm: Bool = false

	var body: some View {
		Button("Remove All Caches") {
			isConfirm = true
		}
		.foregroundColor(.blue)
		.alert("Remove Caches", isPresented: $isConfirm) {
			Button("Remove All Caches", role: .destructive) {
				viewModel.resetAllCaches()
			}

			Button("Cancel", role: .cancel) {
				isConfirm = false
			}
		} message: {
			Text("Are you sure you want to continue? This will remove all caches.")
		}
		.settingsPadding()
	}
}

struct DataSettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	var body: some View {
		SettingsPreferredList {
			Section {
				RemoveCacheButton(viewModel: viewModel)
			} footer: {
				if let storageSize = viewModel.storageSize {
					Text("Cache Size: \(storageSize)")
						.transition(.opacity)
				}
			}
			.animation(.easeInOut(duration: 0.333), value: viewModel.storageSize)
		}
		.task {
			await viewModel.updateStorageSize()
		}
		.navigationTitle("Data")
		.modifier(SharedSettingsPaneModifier())
	}
}
