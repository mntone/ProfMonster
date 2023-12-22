import SwiftUI

#if !os(macOS)

@available(iOS 16.0, watchOS 9.0, *)
@available(macOS, unavailable)
struct DrillDownSettingsContainer: View {
	let viewModel: SettingsViewModel

	@Binding
	var selectedSettingsPanes: [SettingsPane]

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
			Form {
				ForEach(SettingsPane.allCases) { pane in
					NavigationLink(value: pane) {
						pane.label
					}
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
	}
}

@available(macOS, unavailable)
struct DrillDownSettingsContainerBackport: View {
	private let viewModel: SettingsViewModel

#if os(watchOS)
	@Environment(\.dismiss)
	private var dismiss
#endif

	@Binding
	var selectedSettingsPane: SettingsPane?

	init(viewModel: SettingsViewModel,
		 selection selectedSettingsPane: Binding<SettingsPane?> = .constant(nil)) {
		self.viewModel = viewModel
		self._selectedSettingsPane = selectedSettingsPane
	}

	var body: some View {
		NavigationView {
			Form {
				ForEach(SettingsPane.allCases) { pane in
					NavigationLink(tag: pane, selection: $selectedSettingsPane) {
						pane.view(viewModel)
							.navigationBarTitleDisplayMode(.inline)
					} label: {
						pane.label
					}
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
