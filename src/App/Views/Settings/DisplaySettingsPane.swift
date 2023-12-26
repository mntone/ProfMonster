import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	var body: some View {
		Form {
#if os(watchOS)
			Toggle("Element Attack", isOn: Binding {
				viewModel.elementDisplay != .none
			} set: { value in
				viewModel.elementDisplay = value ? .sign : .none
			})
#else
			PreferredPicker("Element Attack",
							data: WeaknessDisplayMode.allCases,
							selection: $viewModel.elementDisplay) { mode in
				Text(mode.localizedKey)
			}
#endif
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
