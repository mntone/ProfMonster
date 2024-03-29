import MonsterAnalyzerCore
import SwiftUI

struct DisplaySettingsPane: View {
	@AppStorage(settings: \.trailingSwipeAction)
	private var trailingSwipeAction: SwipeAction

#if os(iOS)
	@AppStorage(settings: \.navigationBarHideMode)
	private var navigationBarHideMode: NavigationBarHideMode

	@AppStorage(settings: \.keyboardDismissMode)
	private var keyboardDismissMode: KeyboardDismissMode
#endif

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	@Environment(\.horizontalLayoutMargin)
	private var horizontalLayoutMargin

	@StateObject
	private var viewModel = DisplaySettingsViewModel()

	var body: some View {
		SettingsPreferredList {
			SettingsSection("Monster List") {
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
							Toggle("Arrange Variant After Original", isOn: Binding {
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
								Text("Arrange Variant After Original")
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
							   selection: $trailingSwipeAction) {
					ForEach(SwipeAction.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { action in
					Text(action.label)
				}
			}

			SettingsSection("Monster") {
				SettingsToggle("Show Physical Weaknesses",
							   isOn: $viewModel.showPhysicalAttack)

#if os(watchOS)
				SettingsToggle("Element Attack", isOn: Binding {
					viewModel.elementAttack != .none
				} set: { value in
					viewModel.elementAttack = value ? .sign : .none
				})
#else
				SettingsPicker("Element Attack",
							   selection: $viewModel.elementAttack) {
					ForEach(ElementWeaknessDisplayMode.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { mode in
					Text(mode.label)
				} more: {
#if os(iOS)
					if let previewData = viewModel.elementAttackPreview {
						Section("Preview") {
							WeaknessView(viewModel: previewData)
								.id(viewModel.elementAttack)
								.padding(.horizontal, (DynamicTypeSize.xxLarge...DynamicTypeSize.xxxLarge).contains(dynamicTypeSize) ? horizontalLayoutMargin : 0.0)
								.fixedSize(horizontal: false, vertical: true)
								.listRowBackground(EmptyView())
								.listRowInsets(.zero)
								.listRowSeparator(.hidden)
						}
					}
#endif
				}
#endif

				SettingsToggle("Merge Parts with Same Physiology", isOn: $viewModel.mergeParts)

#if os(iOS)
				if UIDevice.current.systemName == "iOS" {
					SettingsPicker("Navigation Bar",
								   selection: $navigationBarHideMode) {
						ForEach(NavigationBarHideMode.allCases) { mode in
							Text(mode.label).tag(mode)
						}
					} label: { mode in
						Text(mode.label)
					}
				}

				SettingsPicker("Keyboard Dismiss",
							   selection: $keyboardDismissMode) {
					ForEach(KeyboardDismissMode.allCases) { mode in
						Text(mode.label).tag(mode)
					}
				} label: { mode in
					Text(mode.label)
				}
#endif
			}
		}
		.navigationTitle("Display")
		.modifier(SharedSettingsPaneModifier())
	}
}
