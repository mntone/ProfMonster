import SwiftUI

struct DeveloperMonsterView: View {
	let dict: [(String, String)]

	init(viewModel: MonsterViewModel) {
		self.dict = [
			("ID", viewModel.id),
			("Type", viewModel.type),
			("Name", viewModel.name),
			("Readable Name", viewModel.readableName),
			("Sortkey", viewModel.sortkey),
			("Another Name", viewModel.anotherName ?? "None"),
			("Keywords", viewModel.keywords.joined(separator: ", "))
		]
	}

	var body: some View {
		Section("Developer") {
			ForEach(dict, id: \.0) { (label, content) in
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

#Preview {
	let viewModel = MonsterViewModel(id: "gulu_qoo", for: "mockgame")!
	return Form {
		MonsterView(viewModel: viewModel)
	}
	.block {
		if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
			$0.formStyle(.grouped)
		} else {
			$0
		}
	}
	.headerProminence(.increased)
}
