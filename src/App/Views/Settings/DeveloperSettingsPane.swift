import MonsterAnalyzerCore
import SwiftUI

struct DeveloperSettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	var body: some View {
		Form {
			Section {
				Toggle("Show Internal Information",
					   isOn: $viewModel.showInternalInformation)
			}
		}
		.navigationTitle("Developer")
		.modifier(SharedSettingsPaneModifier())
	}
}
