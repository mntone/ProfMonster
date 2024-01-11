import MonsterAnalyzerCore
import SwiftUI

struct ContentView: View {
#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass
#endif

	@StateObject
	private var coord = CoordinatorViewModel()

#if !os(macOS)
	@State
	private var isSettingsPresented: Bool = false
#endif

	var body: some View {
		Group {
#if os(macOS)
			if #available(macOS 13.0, *) {
				NavigationSplitViewHost()
			} else {
				NavigationSplitViewHostBackport()
			}
#elseif os(watchOS)
			if #available(watchOS 9.0, *) {
				NavigationStackHost()
			} else {
				NavigationStackHostBackport()
			}
#else
			if UIDevice.current.userInterfaceIdiom == .pad,
			   horizontalSizeClass == .regular {
				if #available(iOS 16.0, *) {
					NavigationSplitViewHost()
				} else {
					NavigationSplitViewHostBackport()
				}
			} else if #available(iOS 16.0, *) {
				NavigationStackHost()
			} else {
				NavigationStackHostBackport()
			}
#endif
		}
#if !os(macOS)
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainer()
		}
		.setPresentSettingsSheetAction(isPresented: $isSettingsPresented)
#endif
		.environmentObject(coord)
		.environment(\.settings, Self.getSettings())
	}

	private static func getSettings() -> MonsterAnalyzerCore.Settings {
		let settings = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self)!.settings
		return settings
	}
}
