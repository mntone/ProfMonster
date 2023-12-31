import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

#if !os(watchOS)
	private let mockData: [WeaknessSectionViewModel] = {
		let mock = MockData.physiology(.guluQoo)!
		let baseViewModel = WeaknessSectionViewModel("settings", rawValue: mock.sections[0])
		return [baseViewModel]
	}()
#endif

	var body: some View {
		SettingsPreferredList {
			Section("Monster List") {
#if os(watchOS)
				SettingsPicker("Sort﻿ by",
							   selection: $viewModel.sort) {
					ForEach(Sort.allOrderCases(reversed: viewModel.sort.isReversed)) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { action in
					Text(action.fullLabel)
				} more: {
					Section {
						SettingsToggle("Reverse", isOn: Binding {
							viewModel.sort.isReversed
						} set: { _ in
							viewModel.sort = viewModel.sort.reversed()
						})
					}
				}
#endif

#if !os(macOS)
				SettingsPicker("Left Swipe",
							   selection: $viewModel.trailingSwipeAction) {
					ForEach(SwipeAction.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { action in
					Text(action.label)
				}
#endif

#if !os(watchOS)
				SettingsToggle("Include Favorite Group in Search Results",
							   isOn: $viewModel.includesFavoriteGroupInSearchResult)
#endif
			}

			Section {
#if os(iOS)
				if !isAccessibilitySize {
					SettingsToggle("Show Monster’s Title", isOn: $viewModel.showTitle)
				}
#endif

#if os(watchOS)
				SettingsToggle("Show Element Attack", isOn: Binding {
					viewModel.elementDisplay != .none
				} set: { value in
					viewModel.elementDisplay = value ? .sign : .none
				})
#else
				SettingsPicker("Element Attack",
							   selection: $viewModel.elementDisplay) {
					ForEach(WeaknessDisplayMode.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { mode in
					Text(mode.label)
				} more: {
					let mode = viewModel.elementDisplay
					if mode != .none {
						Section("Preview") {
							let viewModel = WeaknessViewModel(id: "settings", displayMode: mode, sections: mockData)
							FixedWidthWeaknessView(viewModel: viewModel)
								.settingsPadding()
						}
					}
				}
#endif

				SettingsToggle("Merge Parts with Same Physiology*", isOn: $viewModel.mergeParts)
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
