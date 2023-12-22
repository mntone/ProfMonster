import MonsterAnalyzerCore
import SwiftUI

struct AppSettingsPane: View {
	var body: some View {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			Form {
				LabeledContent("Version", value: AppUtil.bundleVersion)

				LabeledContent("Git Commit Hash") {
					let gitHash = AppUtil.gitHash
					Link(gitHash, destination: URL(string: "https://github.com/mntone/ProfMonster/commit/\(gitHash)")!)
				}

				LabeledContent("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
			}
#if os(watchOS)
			.labeledContentStyle(.vertical)
#endif
			.navigationTitle("App")
			.modifier(SharedSettingsPaneModifier())
		} else {
			Form {
				LabeledContentBackport("Version", value: AppUtil.bundleVersion)

				LabeledContentBackport("Git Commit Hash") {
					let gitHash = AppUtil.gitHash
					Link(gitHash, destination: URL(string: "https://github.com/mntone/ProfMonster/commit/\(gitHash)")!)
				}

				LabeledContentBackport("Git Commit Date", value: AppUtil.gitDate.formatted(date: .numeric, time: .complete))
			}
			.navigationTitle("App")
			.modifier(SharedSettingsPaneModifier())
		}
	}
}
