import SwiftUI

@available(iOS 16.0, *)
@available(watchOS, unavailable)
struct MonsterList: View {
	@StateObject
	var viewModel = GameViewModel()

	let id: GameViewModel.ID
	let selection: Binding<GameItemViewModel.ID?>

	@ViewBuilder
	private var list: some View {
		let items = viewModel.items
		if items.count > 1 || items.first?.type.isType == true {
			List(items, id: \.id, selection: selection) { group in
				Section(group.label) {
					ForEach(group.items) { item in
						MonsterListItem(viewModel: item.content)
					}
				}
			}
		} else {
			List(items.first?.items ?? [], id: \.id, selection: selection) { item in
				MonsterListItem(viewModel: item.content)
			}
		}
	}

	var body: some View {
		list
#if os(macOS)
			.backport.alternatingRowBackgrounds()
			.animation(ProcessInfo.processInfo.isLowPowerModeEnabled ? nil : .default,
					   value: viewModel.items)
#endif
#if os(iOS)
			.scrollDismissesKeyboard(.immediately)
#endif
			.navigationTitle(viewModel.name.map(Text.init) ?? Text("Unknown"))
			.modifier(StatusOverlayModifier(state: viewModel.state))
			.modifier(SharedMonsterListModifier(sort: $viewModel.sort,
												searchText: $viewModel.searchText))
			.onChangeBackport(of: id, initial: true) { _, newValue in
				viewModel.set(id: newValue)
			}
	}
}

@available(iOS 16.0, *)
@available(watchOS, unavailable)
#Preview {
	MonsterList(id: "mockgame", selection: .constant(nil))
}
