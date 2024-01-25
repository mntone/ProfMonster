import SwiftUI

struct ResetSettingsButton: View {
	let viewModel: SettingsViewModel

	@State
	private var isConfirm: Bool = false

	var body: some View {
		Button("Reset All Settings") {
			isConfirm = true
		}
		.alert("Reset Settings", isPresented: $isConfirm) {
			Button("Reset All Settings", role: .destructive) {
				viewModel.resetAllSettings()
			}

			Button("Cancel", role: .cancel) {
				isConfirm = false
			}
		} message: {
			Text("Are you sure you want to continue? This will reset all settings.")
		}
		.tint(.blue)
	}
}
