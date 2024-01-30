import SwiftUI

struct DeveloperSettingsPane: View {
#if DEBUG
	@AppStorage(settings: \.delayNetworkRequest)
	private var delayNetworkRequest: Bool
#endif

	@AppStorage(settings: \.showInternalInformation)
	private var showInternalInformation: Bool

	@AppStorage(settings: \.monsterRowStyle)
	private var monsterRowStyle: String

	var body: some View {
		SettingsPreferredList {
			Section {
#if DEBUG
				SettingsToggle(verbatim: "Delay Network Request",
							   isOn: $delayNetworkRequest)
#endif

				SettingsToggle("Internal Information",
							   isOn: $showInternalInformation)

				SettingsPicker("Row Style",
							   selection: $monsterRowStyle) {
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
