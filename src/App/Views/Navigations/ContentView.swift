import MonsterAnalyzerCore
import SwiftUI

struct ContentView: View {
	@AppStorage(settings: \.firstTime)
	private var firstTime: Bool

	@AppStorage(settings: \.source)
	private var source: String

#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass

	@EnvironmentObject
	private var sceneDelegate: SceneDelegate
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
		.id(source)
		.alert("Caution", isPresented: $firstTime) {
			Button("I Understand") {
				firstTime = false
			}
		} message: {
			Text("Prof. Monster is 3rd party app. Please **DO NOT contact** Capcom about the contents.")
		}
#if !os(macOS)
		.sheet(isPresented: $isSettingsPresented) {
			SettingsContainer()
		}
		.setShowSettings(isPresented: $isSettingsPresented)
#endif
#if os(iOS)
		.environment(\.mobileMetrics, DynamicMobileMetrics(sceneDelegate.window))
#endif
	}
}
