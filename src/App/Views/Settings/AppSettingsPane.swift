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
			Text(verbatim: gitOrigin)
			+ Text(verbatim: "..")
			+ Text(verbatim: gitCurrent.contains(".") ? gitCurrent : String(gitCurrent.prefix(7)))
		}
	}

	var body: some View {
		Form {
			Section {
				VStack {
#if os(macOS)
					if let appIcon = NSImage(named: "AppIcon") {
						Image(nsImage: appIcon)
							.resizable()
							.clipShape(RoundedRectangle(cornerRadius: 23.0))
							.frame(width: 128.0, height: 128.0)
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
					}
#endif

					Text("Prof. Monster")
						.font(.headline)
					Text("Version \(AppUtil.version)")
						.font(.subheadline)
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
				if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
					LabeledContent("Git Difference") {
						hashContent
					}

					LabeledContent("Git Commit Hash", value: AppUtil.gitHash)
					LabeledContent("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
				} else {
					LabeledContentBackport("Git Difference") {
						hashContent
					}

					LabeledContentBackport("Git Commit Hash", value: AppUtil.gitHash)
					LabeledContentBackport("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
				}
			}

			Section("LICENSES") {
				let mit = Self.loadLicense(of: "mit")!
				LicenseView(name: "MessagePacker",
							link: URL(string: "https://github.com/hirotakan/MessagePacker"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "Copyright (c) 2018 hiro"))
#if os(iOS)
				LicenseView(name: "SwiftUI Introspect",
							link: URL(string: "https://github.com/siteline/swiftui-introspect"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "Copyright 2019 Timber Software"))
#endif
				LicenseView(name: "Swinject",
							link: URL(string: "https://github.com/Swinject/Swinject"),
							text: mit.replacingOccurrences(of: "{Copyright}", with: "Copyright (c) 2015 Swinject Contributors"))
			}
			.labelStyle(.iconOnly)
		}
#if os(watchOS)
		.block { content in
			if #available(watchOS 9.0, *) {
				content.labeledContentStyle(.vertical)
			} else {
				content
			}
		}
#endif
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
