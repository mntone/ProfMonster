import MonsterAnalyzerCore
import SwiftUI

struct AppSettingsPane: View {
#if os(watchOS)
	@Environment(\.watchMetrics)
	private var watchMetrics
#endif

	private var hashContent: some View {
		let gitCurrent = AppUtil.gitCurrent
		let gitOrigin = AppUtil.gitOrigin
		return Link(destination: URL(string: "https://github.com/mntone/ProfMonster/compare/\(gitOrigin)...\(gitCurrent)")!) {
			Text(gitOrigin)
			+ Text(verbatim: "..")
			+ Text(gitCurrent.contains(".") ? gitCurrent : String(gitCurrent.prefix(7)))
		}
	}

	var body: some View {
		SettingsPreferredList {
			Section {
				VStack {
#if os(macOS)
					if let appIcon = NSImage(named: "AppIcon") {
						Image(nsImage: appIcon)
							.resizable()
							.clipShape(RoundedRectangle(cornerRadius: 23.0))
							.frame(width: 128.0, height: 128.0)
							.accessibilityHidden(true)
					}
#else
					if let appIcon = UIImage(named: "AppIcon") {
#if os(watchOS)
						let iconSize = watchMetrics.iconSize
#endif
						Image(uiImage: appIcon)
							.resizable()
#if os(watchOS)
							.clipShape(Circle())
							.frame(width: iconSize, height: iconSize)
#else
							.clipShape(RoundedRectangle(cornerRadius: 13.5))
							.frame(width: 60.0, height: 60.0)
#endif
							.accessibilityHidden(true)
					}
#endif

					Text("Prof. Monster")
						.font(.headline)
					Text("Version \(AppUtil.version) (\(AppUtil.shortVersion))")
						.font(.subheadline)
					Spacer()
					Text(AppUtil.copyright)
#if os(watchOS)
						.font(.footnote)
#else
						.font(.subheadline)
#endif
#if os(macOS)
						.textSelection(.enabled)
#endif
				}
				.scenePadding()
				.frame(maxWidth: .infinity)
			}
#if !os(macOS)
			.listRowBackground(EmptyView())
#endif
#if os(iOS)
			.listRowSeparator(.hidden)
#endif

			Section("Build Info") {
				let gitHash = AppUtil.gitHash
				SettingsLabeledContent(LocalizedStringKey("Git Difference")) {
					hashContent
				}

				SettingsLabeledContent(LocalizedStringKey("Git Commit Hash"), value: String(gitHash.prefix(7)))
#if os(watchOS)
					.listRowBackground(EmptyView())
#else
					.help(gitHash)
#endif
				SettingsLabeledContent(LocalizedStringKey("Git Commit Date"), value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
#if os(watchOS)
					.listRowBackground(EmptyView())
#endif
			}

			Section("LICENSES") {
				let mit = Self.loadLicense(of: "mit")!
				LicenseView(name: "MessagePacker",
							link: URL(string: "https://github.com/hirotakan/MessagePacker"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "(c) 2018 hiro"))
#if os(iOS) || os(macOS)
				LicenseView(name: "SwiftUI Introspect",
							link: URL(string: "https://github.com/siteline/swiftui-introspect"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "2019 Timber Software"))
#endif
				LicenseView(name: "Swinject",
							link: URL(string: "https://github.com/Swinject/Swinject"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "(c) 2015 Swinject Contributors"))
			}
			.labelStyle(.iconOnly)
		}
		.navigationTitle("About App")
		.modifier(SharedSettingsPaneModifier())
	}

	private static func loadLicense(of type: String) -> String? {
		guard let path = Bundle.main.path(forResource: type, ofType: "txt") else { return nil }
		let text = try? String(contentsOfFile: path, encoding: .utf8)
		return text
	}
}

@available(macOS 13.0, *)
#Preview {
	AppSettingsPane()
#if os(macOS)
		.formStyle(.grouped)
#endif
		.previewLayout(.sizeThatFits)
#if os(watchOS)
		.environment(\.watchMetrics, WatchUtil.getMetrics())
#endif

}
