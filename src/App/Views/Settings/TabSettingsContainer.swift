import SwiftUI

#if os(macOS)

@available(iOS, unavailable)
@available(macOS, introduced: 11.0, deprecated: 12.0, message: "Use ColumnSettingsContainer instead")
@available(watchOS, unavailable)
struct TabSettingsContainer: View {
	let viewModel: SettingsViewModel

	@Environment(\.dismiss)
	private var dismiss

	@State
	private var selectedSettingsPane: SettingsPane = .display

	var body: some View {
		TabView(selection: $selectedSettingsPane) {
			ForEach(SettingsPane.allCases) { pane in
				pane.view(viewModel)
					.tabItem {
						pane.label
					}
					.tag(pane)
			}
		}
		.padding(EdgeInsets(top: 20,
							leading: 80,
							bottom: 20,
							trailing: 20))
		.onExitCommand(perform: dismiss.callAsFunction)
		.frame(width: 540)
	}
}

@available(iOS, unavailable)
@available(watchOS, unavailable)
#Preview {
	let viewModel = SettingsViewModel(rootViewModel: HomeViewModel())
	return TabSettingsContainer(viewModel: viewModel)
}

#endif