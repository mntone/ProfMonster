import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

	var body: some View {
		Form {
			Section("Monster List") {
#if !os(macOS)
				PreferredPicker("Left Swipe",
								data: SwipeAction.allCases,
								selection: $viewModel.trailingSwipeAction) { mode in
					Text(verbatim: mode.label)
				}
#endif

#if !os(watchOS)
				Toggle("Include Favorite Group in Search Results",
					   isOn: $viewModel.includesFavoriteGroupInSearchResult)
#endif

#if os(iOS)
				if !isAccessibilitySize {
					Toggle("Show Monster’s Title", isOn: $viewModel.showTitle)
				}
#endif
			}

			Section{
#if os(watchOS)
				Toggle("Show Element Attack", isOn: Binding {
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

				Toggle("Merge Parts with Same Physiology*", isOn: $viewModel.mergeParts)
			} header: {
				Text("Monster Detail")
			} footer: {
				Text("The asterisk (*) settings will take effect when you restart the app.")
#if os(macOS)
					.foregroundStyle(.secondary)
#endif
			}
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
