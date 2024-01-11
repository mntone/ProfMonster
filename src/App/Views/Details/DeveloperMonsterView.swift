import SwiftUI

struct DeveloperMonsterView: View {
	let pairs: [(String, String)]

	var body: some View {
		Section("Developer") {
			ForEach(pairs, id: \.0) { (label, content) in
				SettingsLabeledContent(label) {
					Text(content)
#if os(macOS)
						.textSelection(.enabled)
#endif
						.foregroundStyle(.secondary)
				}
			}
		}
#if os(watchOS)
		.listRowBackground(EmptyView())
#endif
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return Form {
		DeveloperMonsterView(pairs: viewModel.pairs)
	}
	.formStyle(.grouped)
	.headerProminence(.increased)
}
