import SwiftUI

struct DataSettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	var body: some View {
		SettingsPreferredList {
			Section {
				ResetSettingsButton(viewModel: viewModel)
				ResetCacheButton(viewModel: viewModel)
			} footer: {
				if let storageSize = viewModel.storageSize {
					Text("Cache Size: \(storageSize)")
						.transition(.opacity)
				}
			}
			.animation(.default, value: viewModel.storageSize)
		}
		.task {
			await viewModel.updateStorageSize()
		}
		.navigationTitle("Data")
		.modifier(SharedSettingsPaneModifier())
	}
}
