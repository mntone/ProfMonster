import SwiftUI

enum WeaknessDisplayMode: String, CaseIterable, Identifiable {
	case none = "Off"
	case sign = "Sign"
	case number = "Number"

	var id: String {
		rawValue
	}

	var localizedStringKey: LocalizedStringKey {
		LocalizedStringKey(rawValue)
	}
}

struct DisplaySettingsPane: View {
	@State
	var elementAttack: WeaknessDisplayMode = .sign

	var body: some View {
		Form {
#if os(watchOS)
			Toggle("Element Attack", isOn: Binding {
				elementAttack != .none
			} set: { value in
				elementAttack = value ? .sign : .none
			})
#else
			PreferredPicker("Element Attack",
							data: WeaknessDisplayMode.allCases,
							selection: $elementAttack) { mode in
				Text(mode.localizedStringKey)
			}
#endif
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
