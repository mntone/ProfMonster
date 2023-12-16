import MonsterAnalyzerCore
import SwiftUI
import Swinject

@main
struct MAApp: SwiftUI.App {
#if os(macOS)
	@NSApplicationDelegateAdaptor
	private var appDelegate: MAAppDelegate
#elseif os(watchOS)
	@WKApplicationDelegateAdaptor
	private var appDelegate: MAAppDelegate
#endif

	private let viewModel = HomeViewModel()

	var body: some Scene {
		WindowGroup {
			ContentView(viewModel: viewModel)
				.environmentObject(viewModel)
		}
#if os(watchOS)
		.environment(\.watchMetrics, WatchUtil.getMetrics())
#endif

#if os(macOS)
		Settings {
			SettingsView(viewModel: SettingsViewModel(rootViewModel: viewModel))
		}
#endif
	}

	fileprivate(set) static var crashed: Bool = false

	static func resetCrashed() {
		crashed = false
	}

	private(set) static var container = Container()

	static var resolver: Resolver = {
		return Assembler([
			CoreAssembly(),
		], container: container).resolver
	}()
}

#if os(macOS)
final class MAAppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
#if !DEBUG
		// Skip crash detection on DEBUG
		MAApp.crashed = UserDefaults.standard.bool(forKey: "crashed")
#endif
		crashedLastTime = true
	}

	func applicationWillTerminate(_ notification: Notification) {
		crashedLastTime = false
	}
}
#elseif os(watchOS)
final class MAAppDelegate: NSObject, WKApplicationDelegate {
	func applicationDidFinishLaunching() {
#if !targetEnvironment(simulator)
		// Skip crash detection on simulator
		MAApp.crashed = crashedLastTime
#endif
		crashedLastTime = true
	}

	func applicationWillResignActive() {
		crashedLastTime = true
	}

	func applicationDidEnterBackground() {
		crashedLastTime = false
	}
}
#endif

#if !os(iOS)
extension MAAppDelegate {
	var crashedLastTime: Bool {
		get {
			UserDefaults.standard.bool(forKey: "crashed")
		}
		set {
			UserDefaults.standard.setValue(newValue, forKey: "crashed")
		}
	}
}
#endif
