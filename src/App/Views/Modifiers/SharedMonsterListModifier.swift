import MonsterAnalyzerCore
import SwiftUI

struct SharedMonsterListModifier: ViewModifier {
#if !os(watchOS)
	@Binding
	private(set) var sort: Sort
#endif

	let searchText: Binding<String>

	func body(content: Content) -> some View {
		content
#if !os(watchOS)
			.toolbar {
				ToolbarItem(placement: .primaryAction) {
					Menu("Sort by", systemImage: "arrow.up.arrow.down.circle") {
#if os(macOS)
						Picker(selection: $sort) {
							ForEach(Sort.allOrderCases(reversed: sort.isReversed)) { item in
								Text(item.label).tag(item)
							}
						} label: {
							Never?.none
						}
						.pickerStyle(.inline)

						Divider()

						Toggle("Reverse", isOn: Binding {
							sort.isReversed
						} set: { _ in
							sort = sort.reversed()
						})
#else
						Toggle(isOn: Binding {
							sort.isInGame
						} set: { newValue in
							if !newValue {
								sort = .inGame(reversed: !sort.isReversed)
							} else {
								sort = .inGame(reversed: false)
							}
						}) {
							switch sort {
							case let .inGame(reversed):
								Label("In Game", systemImage: reversed ? "chevron.up" : "chevron.down")
							default:
								Text("In Game")
							}
						}

						Toggle(isOn: Binding {
							sort.isName
						} set: { newValue in
							if !newValue {
								sort = .name(reversed: !sort.isReversed)
							} else {
								sort = .name(reversed: false)
							}
						}) {
							switch sort {
							case let .name(reversed):
								Label("Name", systemImage: reversed ? "chevron.up" : "chevron.down")
							default:
								Text("Name")
							}
						}

						Toggle(isOn: Binding {
							sort.isType
						} set: { newValue in
							if !newValue {
								sort = .type(reversed: !sort.isReversed)
							} else {
								sort = .type(reversed: false)
							}
						}) {
							switch sort {
							case let .type(reversed):
								Label("Type", systemImage: reversed ? "chevron.up" : "chevron.down")
							default:
								Text("Type")
							}
						}

						Toggle(isOn: Binding {
							sort.isWeakness
						} set: { newValue in
							if !newValue {
								sort = .weakness(reversed: !sort.isReversed)
							} else {
								sort = .weakness(reversed: false)
							}
						}) {
							switch sort {
							case let .weakness(reversed):
								Label("Weakness", systemImage: reversed ? "chevron.up" : "chevron.down")
							default:
								Text("Weakness")
							}
						}
#endif
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
#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
#endif
	}
}
