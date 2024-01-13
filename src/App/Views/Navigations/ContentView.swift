import MonsterAnalyzerCore
import SwiftUI

struct ContentView: View {
#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
#endif

#if !os(macOS)
	@State
	private var isSettingsPresented: Bool = false
#endif

	var body: some View {
		Group {
#if os(macOS)
			ColumnContentView()
#elseif os(watchOS)
			StackContentView()
#else
			if UIDevice.current.userInterfaceIdiom == .pad,
			   horizontalSizeClass == .regular {
				ColumnContentView()
			} else {
				StackContentView()
			}
#endif
		}
#if !os(macOS)
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainer()
		}
		.setPresentSettingsSheetAction(isPresented: $isSettingsPresented)
#endif
		.environment(\.settings, Self.getSettings())
	}

	private static func getSettings() -> MonsterAnalyzerCore.Settings {
		let settings = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self)!.settings
		return settings
	}
}
