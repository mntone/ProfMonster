import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

	var body: some View {
		Form {
#if !os(watchOS)
			Section {
				Toggle("Include Favorite Group in Search Results",
					   isOn: $viewModel.includesFavoriteGroupInSearchResult)

#if os(iOS)
				if !isAccessibilitySize {
					Toggle("Show Monster’s Title", isOn: $viewModel.showTitle)
				}
#endif
			}
#endif

			Section("Weakness") {
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
					Text(verbatim: mode.label)
				}
#endif
			}

			Section {
				Toggle("Merge parts with the same status", isOn: $viewModel.mergeParts)
			} header: {
				Text("Physiology")
			} footer: {
				Text("The settings will take effect when you restart the app.")
#if os(macOS)
					.foregroundStyle(.secondary)
#endif
			}
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
