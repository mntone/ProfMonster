import MonsterAnalyzerCore
import SwiftUI

struct MonsterListItem: View {
	@ObservedObject
	private var viewModel: MonsterViewModel

	init(_ viewModel: MonsterViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		Text(verbatim: viewModel.name ?? viewModel.id)
			.redacted(reason: viewModel.name == nil ? .placeholder : [])
	}
}

#Preview {
	MonsterListItem(MonsterViewModel("gulu_qoo", of: "mockgame"))
}
