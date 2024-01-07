import SwiftUI

#if os(macOS)

@available(iOS, unavailable)
@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use ColumnSettingsContainer instead")
@available(watchOS, unavailable)
struct TabSettingsContainer: View {
	@StateObject
	private var viewModel = SettingsViewModel()

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
	return TabSettingsContainer()
}

#endif
