import MonsterAnalyzerCore
import SwiftUI

#if !os(macOS)

@available(macOS, unavailable)
struct SettingsContainer: View {
#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
#endif

	@State
	private var selectedSettingsPane: SettingsPane?

	var body: some View {
#if os(watchOS)
		if #available(watchOS 9.0, *) {
			DrillDownSettingsContainer(selection: $selectedSettingsPane)
		} else {
			DrillDownSettingsContainerBackport(selection: $selectedSettingsPane)
		}
#else
		if UIDevice.current.userInterfaceIdiom == .pad,
		   horizontalSizeClass == .regular {
			ColumnSettingsContainer(selection: $selectedSettingsPane)
		} else if #available(iOS 16.0, *) {
			DrillDownSettingsContainer(selection: $selectedSettingsPane)
		} else {
			DrillDownSettingsContainerBackport(selection: $selectedSettingsPane)
		}
#endif
	}
}

#endif
