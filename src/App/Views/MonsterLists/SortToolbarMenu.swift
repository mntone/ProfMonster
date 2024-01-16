import MonsterAnalyzerCore
import SwiftUI

@available(watchOS, unavailable)
struct SortToolbarMenu: View {
	@Binding
	private(set) var sort: Sort

	@Binding
	private(set) var groupOption: GroupOption

#if os(iOS)
	@ViewBuilder
	private var menuContent: some View {
		Section("Sort By:") {
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
		}

		Divider()

		Section("Group By:") {
			Toggle("None", isOn: Binding {
				groupOption.isNone
			} set: { newValue in
				if newValue {
					groupOption = .none
				}
			})

			Toggle("Type", isOn: Binding {
				groupOption.isType
			} set: { newValue in
				if newValue {
					groupOption = .type
				}
			})

			Toggle("Weakness", isOn: Binding {
				groupOption.isWeakness
			} set: { newValue in
				if newValue {
					groupOption = .weakness
				}
			})
		}
	}
#endif

	var body: some View {
#if os(macOS)
		Menu("View Options", systemImage: "arrow.up.arrow.down.circle") {
			Picker("Sort By:", selection: $sort) {
				ForEach(Sort.allOrderCases(reversed: sort.isReversed)) { item in
					Text(item.label).tag(item)
				}
			}
			.pickerStyle(.inline)

			Toggle("Reverse", isOn: Binding {
				sort.isReversed
			} set: { _ in
				sort = sort.reversed()
			})

			Divider()

			Picker("Group By:", selection: $groupOption) {
				ForEach(GroupOption.allCases) { item in
					Text(item.label).tag(item)
				}
			}
			.pickerStyle(.inline)
		}
#endif
#if os(iOS)
		if #available(iOS 17.0, *) {
			Menu("View Options", systemImage: "arrow.up.arrow.down.circle") {
				menuContent
			}
		} else {
			Menu {
				menuContent
			} label: {
				Image(systemName: "arrow.up.arrow.down.circle")
					.frame(height: 36)
					.padding(.leading, 8)
					.padding(.trailing)
			}
		}
#endif
	}
}
