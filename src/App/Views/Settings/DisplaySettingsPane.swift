import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@ObservedObject
	private(set) var viewModel: SettingsViewModel

#if !os(watchOS)
	private let mockData: Physiology = {
		let mock = MockData.physiology(.guluQoo)!
		return mock.modes[0]
	}()
#endif

	var body: some View {
		SettingsPreferredList {
			Section("Monster List") {
#if os(watchOS)
				NavigationLink {
					Form {
						Picker("Sort By:", selection: $viewModel.sort) {
							ForEach(Sort.allOrderCases(reversed: viewModel.sort.isReversed, linked: viewModel.sort.isLinked)) { item in
								Text(item.label).tag(item)
							}
						}
						.pickerStyle(.inline)

						if viewModel.sort.isName {
							Toggle("Place Variant After Original", isOn: Binding {
								viewModel.sort.isLinked
							} set: { _ in
								viewModel.sort = viewModel.sort.toggleLinked()
							})
						}

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
					SettingsLabeledContent(LocalizedStringKey("View Options")) {
						VStack(alignment: .leading, spacing: 0) {
							HStack(alignment: .firstTextBaseline) {
								Text("Sort By:")
								Text(viewModel.sort.fullLabel)
							}

							if viewModel.sort.isName,
							   viewModel.sort.isLinked {
								Text("Variant After Original")
							}

							if !viewModel.groupOption.isNone {
								HStack(alignment: .firstTextBaseline) {
									Text("Group By:")
									Text(viewModel.groupOption.label)
								}
							}
						}
						.font(.caption)
						.foregroundStyle(.secondary)
					}
				}
#endif

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
				SettingsToggle("Physical Attack",
							   isOn: $viewModel.showPhysicalAttack)

#if os(watchOS)
				SettingsToggle("Element Attack", isOn: Binding {
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
							let options = MonsterDataViewModelBuildOptions(physical: viewModel.showPhysicalAttack,
																		   element: mode)
							let viewModel = NumberWeaknessViewModel(prefixID: "settings", physiology: mockData, options: options)
							WeaknessView(viewModel: viewModel)
								.fixedSize(horizontal: false, vertical: true)
								.listRowBackground(EmptyView())
								.listRowInsets(.zero)
						}
					}
				}
#endif

				SettingsToggle("Merge Parts with Same Physiology", isOn: $viewModel.mergeParts)

#if os(iOS)
				SettingsPicker("Keyboard Dismiss",
							   selection: $viewModel.keyboardDismissMode) {
					ForEach(KeyboardDismissMode.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { mode in
					Text(mode.label)
				}
#endif
			} header: {
				Text("Monster Detail")
			}
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
