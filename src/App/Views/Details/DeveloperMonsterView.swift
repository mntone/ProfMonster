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
			if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
				ForEach(dict, id: \.0) { (label, content) in
					LabeledContent {
						Text(verbatim: content)
#if os(macOS)
							.textSelection(.enabled)
#endif
					} label: {
						Text(verbatim: label)
					}
				}
			} else {
				ForEach(dict, id: \.0) { (label, content) in
					LabeledContentBackport {
						Text(verbatim: content)
#if os(macOS)
							.textSelection(.enabled)
#endif
					} label: {
						Text(verbatim: label)
					}
				}
			}
		}
#if os(watchOS)
		.listRowBackground(EmptyView())
		.block { content in
			if #available(watchOS 9.0, *) {
				content.labeledContentStyle(.vertical)
			} else {
				content
			}
		}
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
