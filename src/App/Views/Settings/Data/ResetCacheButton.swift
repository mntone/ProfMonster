import SwiftUI

struct ResetCacheButton: View {
	let viewModel: DataSettingsViewModel

	@State
	private var isConfirm: Bool = false

	var body: some View {
		SettingsButton("Reset All Caches") {
			isConfirm = true
		}
		.alert("Reset Caches", isPresented: $isConfirm) {
			Button("Reset All Caches", role: .destructive) {
				viewModel.resetAllCaches()
			}

			Button("Cancel", role: .cancel) {
				isConfirm = false
			}
		} message: {
			Text("Are you sure you want to continue? This will reset all caches.")
		}
		.tint(.blue)
	}
}
