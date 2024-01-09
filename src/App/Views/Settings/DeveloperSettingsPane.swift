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

				SettingsPicker("Weakness Display Mode in List",
							   selection: $viewModel.test) {
					Text(verbatim: "After Monster Name").tag("A")
					Text(verbatim: "Before Favorite").tag("B")
				} label: { mode in
					Text(mode)
				}
			}
		}
		.navigationTitle("Developer")
		.modifier(SharedSettingsPaneModifier())
	}
}
