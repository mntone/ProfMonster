import MonsterAnalyzerCore
import SwiftUI

struct SharedMonsterListModifier<Data>: ViewModifier {
	let state: StarSwingsState<Data>
	let sort: Binding<Sort>
	let searchText: Binding<String>

	func body(content: Content) -> some View {
		content
#if !os(watchOS)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu("Sort", systemImage: "arrow.up.arrow.down.circle") {
						Picker(selection: sort) {
							Text("In Game", comment: "Sort/In Game").tag(Sort.inGame)
							Text("Name", comment: "Sort/Name").tag(Sort.name)
							Text("Type", comment: "Sort/Type").tag(Sort.type)
						} label: {
							EmptyView()
						}
						.pickerStyle(.inline)
					}
				}
			}
#endif
#if os(watchOS)
			.block { content in
				if #available(watchOS 10.2, *) {
					// The "searchable" is broken on watchOS 10.2.
					content
				} else {
					content.searchable(text: searchText, prompt: Text("Search"))
				}
			}
#else
			.searchable(text: searchText, prompt: Text("Monster and Weakness"))
#endif
			.overlay {
				switch state {
				case .loading:
					ProgressView()
				case let .failure(_, error):
					Text(error.label)
						.scenePadding()
				default:
					EmptyView()
				}
			}
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
	}
}
