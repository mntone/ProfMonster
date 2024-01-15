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
#else
	@UIApplicationDelegateAdaptor
	private var appDelegate: MAAppDelegate
#endif

#if os(iOS)
	init() {
		// Apply patches to UIKit.
		UIView.swizzleNavigationBarContentView()
	}
#endif

	private var defaultWindowGroup: some Scene {
		WindowGroup {
			ContentView()
		}
		.environment(\.settings, Self.settings)
#if os(watchOS)
		.environment(\.watchMetrics, WatchUtil.getMetrics())
#endif
#if os(macOS)
		.commands {
			CommandGroup(replacing: .undoRedo) {
			}

			CommandGroup(replacing: .appInfo) {
				Button("About Prof. Monster") {
					NSApplication.shared.orderFrontStandardAboutPanel(options: [
						.applicationVersion: String(localized: "Version \(AppUtil.version)"),
						.version: AppUtil.shortVersion,
					])
				}
			}

			ToolbarCommands()
			SidebarCommands()
		}
		// Issue: "Swift runtime failure"
		//.defaultSizeBackport(width: 860.0, height: 720.0)
#endif
	}

#if !os(watchOS)
	@available(iOS 16.0, macOS 13.0, *)
	@available(watchOS, unavailable)
	private var monsterWindowGroup: some Scene {
		WindowGroup(id: "monster", for: String.self) { $id in
			if let id {
				MonsterWindow(id: id)
			}
		}
#if os(macOS)
		.commandsRemoved()
		.defaultSize(MonsterWindow.defaultSize)
#else
		// Issue: "Swift runtime failure"
		//.defaultSizeBackport(MonsterWindow.defaultSize)
#endif
		.environment(\.settings, Self.settings)
	}
#endif

	var body: some Scene {
		defaultWindowGroup

#if !os(watchOS)
		if #available(iOS 16.0, macOS 13.0, *) {
			monsterWindowGroup
		}
#endif

#if os(macOS)
		Settings {
			if #available(macOS 13.0, *) {
				ColumnSettingsContainer()
			} else {
				TabSettingsContainer()
			}
		}
#endif
	}

	fileprivate(set) static var crashed: Bool = false

	static func resetCrashed() {
		crashed = false
	}

	static var resolver: Resolver = {
		return Assembler([
			CoreAssembly(),
			AppAssembly(),
		]).resolver
	}()

	private static var settings: MonsterAnalyzerCore.Settings = {
		let settings = MAApp.resolver.resolve(MonsterAnalyzerCore.App.self)!.settings
		return settings
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

	func applicationWillBecomeActive(_ notification: Notification) {
		crashedLastTime = true
	}

	func applicationDidResignActive(_ notification: Notification) {
		crashedLastTime = false
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
#else
final class MAAppDelegate: NSObject, UIApplicationDelegate {
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

	func applicationWillTerminate(_ application: UIApplication) {
		crashedLastTime = false
	}
}
#endif

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
