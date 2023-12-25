import MonsterAnalyzerCore
import SwiftUI

struct AppSettingsPane: View {
	var body: some View {
		Form {
			Section {
				if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
					LabeledContent("Version", value: AppUtil.bundleVersion)

					LabeledContent("Git Commit Hash") {
						let gitHash = AppUtil.gitHash
						Link(gitHash, destination: URL(string: "https://github.com/mntone/ProfMonster/commit/\(gitHash)")!)
					}

					LabeledContent("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
				} else {
					LabeledContentBackport("Version", value: AppUtil.bundleVersion)

					LabeledContentBackport("Git Commit Hash") {
						let gitHash = AppUtil.gitHash
						Link(gitHash, destination: URL(string: "https://github.com/mntone/ProfMonster/commit/\(gitHash)")!)
					}

					LabeledContentBackport("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
				}
			}

			Section("LICENSES") {
				let mit = Self.loadLicense(of: "mit")!
				LicenseView(name: "MessagePacker",
							link: URL(string: "https://github.com/a2/MessagePack.swift"),
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
}
