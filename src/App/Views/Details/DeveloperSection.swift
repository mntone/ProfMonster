import SwiftUI

struct DeveloperSection: View {
	let pairs: [(String, String)]

	var body: some View {
		MASection("Developer") {
			ForEach(pairs, id: \.0) { (label, content) in
				MALabeledString(label, value: content)
			}
		}
	}
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return Form {
		DeveloperSection(pairs: viewModel.pairs)
	}
	.formStyle(.grouped)
	.headerProminence(.increased)
}
