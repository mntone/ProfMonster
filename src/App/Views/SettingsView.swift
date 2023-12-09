import MonsterAnalyzerCore
import SwiftUI

struct RemoveCacheButton: View {
	@State
	private var isConfirm: Bool = false

	@EnvironmentObject
	private var rootViewModel: HomeViewModel

	var body: some View {
		Button("settings.removeCache.action") {
			isConfirm = true
		}
		.foregroundColor(.blue)
		.alert("settings.removeCache.title", isPresented: $isConfirm) {
			Button(role: .destructive) {
				MAApp.resolver.resolve(Storage.self)!.clear()
				rootViewModel.clear()
			} label: {
				Text("settings.removeCache.action")
			}

			Button("settings.removeCache.cancel", role: .cancel) {
				isConfirm = false
			}
		} message: {
			Text("settings.removeCache.message")
		}
	}
}

struct SettingsView: View {
	var body: some View {
		List {
			Section {
				RemoveCacheButton()
			}
		}
		.navigationTitle("settings.title")
#if !os(macOS)
		.navigationBarTitleDisplayMode(.large)
#endif
	}
}

struct SettingsContainerView: View {
	var body: some View {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			NavigationStack {
				SettingsView()
			}
		} else {
			NavigationView {
				SettingsView()
			}
		}
	}
}

#Preview {
	SettingsView()
}
