import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

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
				NavigationLink {
					Form {
						Picker("Sort By:", selection: $viewModel.sort) {
							ForEach(Sort.allOrderCases(reversed: viewModel.sort.isReversed)) { item in
								Text(item.label).tag(item)
							}
						}
						.pickerStyle(.inline)

						Toggle("Reverse", isOn: Binding {
							viewModel.sort.isReversed
						} set: { _ in
							viewModel.sort = viewModel.sort.reversed()
						})

						Picker("Group By:", selection: $viewModel.groupOption) {
							ForEach(GroupOption.allCases) { item in
								Text(item.label).tag(item)
							}
						}
						.pickerStyle(.inline)
					}
					.navigationTitle("View Options")
				} label: {
					SettingsLabeledContent("View Options") {
						VStack(alignment: .leading, spacing: 0) {
							HStack(alignment: .firstTextBaseline) {
								Text("Sort By:")
								Text(viewModel.sort.fullLabel)
							}
							HStack(alignment: .firstTextBaseline) {
								Text("Group By:")
								Text(viewModel.groupOption.label)
							}
						}
						.font(.caption2)
						.foregroundStyle(.secondary)
						.lineLimit(1)
					}
				}
#endif

				SettingsToggle("Place Subspecies near Original Species",
							   isOn: $viewModel.linkSubspecies)

#if !os(watchOS)
				SettingsToggle("Include Favorite Group in Search Results",
							   isOn: $viewModel.includesFavoriteGroupInSearchResult)
#endif

				SettingsPicker("Left Swipe",
							   selection: $viewModel.trailingSwipeAction) {
					ForEach(SwipeAction.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { action in
					Text(action.label)
				}
			}

			Section {
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
								.preferredVerticalPadding()
						}
					}
				}
#endif

				SettingsToggle("Merge Parts with Same Physiology", isOn: $viewModel.mergeParts)
			} header: {
				Text("Monster Detail")
			}
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
