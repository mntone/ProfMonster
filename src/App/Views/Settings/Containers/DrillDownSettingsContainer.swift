import SwiftUI

#if !os(macOS)

struct SettingsList<ItemView: View>: View {
	@ViewBuilder
	let content: (SettingsPane) -> ItemView

	var body: some View {
#if os(iOS)
		List(SettingsPane.allCases, rowContent: content)
#else
		Form {
			ForEach(SettingsPane.allCases, content: content)
		}
#endif
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct DrillDownSettingsContainer: View {
	let viewModel: SettingsViewModel

	@Binding
	var selectedSettingsPanes: [SettingsPane]

	@Environment(\.dynamicTypeSize)
	private var dynamicTypeSize

	init(viewModel: SettingsViewModel,
		 selection selectedSettingsPane: Binding<SettingsPane?>) {
		self.viewModel = viewModel
		self._selectedSettingsPanes = Binding {
			selectedSettingsPane.wrappedValue.map { [$0] } ?? []
		} set: { value in
			switch value.count {
			case 0:
				selectedSettingsPane.wrappedValue = nil
			case 1:
				selectedSettingsPane.wrappedValue = value[0]
			default:
				fatalError()
			}
		}
	}

	var body: some View {
		NavigationStack(path: $selectedSettingsPanes) {
			SettingsList { pane in
				NavigationLink(value: pane) {
					pane.label
				}
			}
			.navigationDestination(for: SettingsPane.self) { pane in
				pane.view(viewModel)
			}
			.navigationBarTitleDisplayMode(.large)
			.modifier(SharedSettingsContainerModifier())
		}
#if os(watchOS)
		.block { content in
			if #available(watchOS 10.0, *) {
				content
			} else {
				// Hide the root navigation bar.
				// Require to show this navigation bar.
				content.navigationBarHidden(true)
			}
		}
#endif
#if os(iOS)
		.block { content in
			switch dynamicTypeSize {
			case .xxLarge, .xxxLarge:
				content.listStyle(.grouped)
			default:
				content.listStyle(.insetGrouped)
			}
		}
#endif
	}
}

@available(macOS, unavailable)
struct DrillDownSettingsContainerBackport: View {
	private let viewModel: SettingsViewModel

	@Binding
	var selectedSettingsPane: SettingsPane?

	init(viewModel: SettingsViewModel,
		 selection selectedSettingsPane: Binding<SettingsPane?> = .constant(nil)) {
		self.viewModel = viewModel
		self._selectedSettingsPane = selectedSettingsPane
	}

	var body: some View {
		NavigationView {
			SettingsList { pane in
				NavigationLink(tag: pane, selection: $selectedSettingsPane) {
					pane.view(viewModel)
						.navigationBarTitleDisplayMode(.inline)
				} label: {
					pane.label
				}
			}
			.navigationBarTitleDisplayMode(.large)
			.modifier(SharedSettingsContainerModifier())
		}
		.navigationViewStyle(.stack)
#if os(watchOS)
		// Hide the root navigation bar.
		// Require to show this navigation bar.
		.navigationBarHidden(true)
#endif
	}
}

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
#Preview {
	let viewModel = SettingsViewModel(rootViewModel: HomeViewModel())
	return DrillDownSettingsContainer(viewModel: viewModel, selection: .constant(nil))
}

#endif
