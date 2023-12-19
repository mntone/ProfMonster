import enum MonsterAnalyzerCore.Sort
import SwiftUI

struct SharedMonsterListModifier: ViewModifier {
	let sort: Binding<Sort>
	let searchText: Binding<String>
	let isLoading: Bool

	func body(content: Content) -> some View {
		content
#if !os(watchOS)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu("Sort", systemImage: "arrow.up.arrow.down.circle") {
						Picker(selection: sort) {
							Text("In Game").tag(Sort.inGame)
							Text("Name").tag(Sort.name)
						} label: {
							EmptyView()
						}
						.pickerStyle(.inline)
					}
				}
			}
#endif
#if os(watchOS)
			.searchable(text: searchText, prompt: Text("Search"))
#else
			.searchable(text: searchText, prompt: Text("Monster and Weakness"))
#endif
			.overlay {
				if isLoading {
					ProgressView()
				}
			}
#if os(macOS)
			.alternatingRowBackgroundsBackport(enable: true)
#else
			.navigationBarTitleDisplayMode(.inline)
#endif
	}
}
