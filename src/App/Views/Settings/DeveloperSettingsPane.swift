import MonsterAnalyzerCore
import SwiftUI

struct DeveloperSettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	var body: some View {
		SettingsPreferredList {
			Section {
				SettingsToggle("Show Internal Information",
							   isOn: $viewModel.showInternalInformation)
			}
		}
		.navigationTitle("Developer")
		.modifier(SharedSettingsPaneModifier())
	}
}
