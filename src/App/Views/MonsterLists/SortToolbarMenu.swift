import MonsterAnalyzerCore
import SwiftUI

@available(watchOS, unavailable)
struct SortToolbarMenu: View {
	@Binding
	private(set) var sort: Sort

#if os(iOS)
	@ViewBuilder
	private var menuContent: some View {
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
	}
#endif

	var body: some View {
#if os(macOS)
		Menu("Sort by", systemImage: "arrow.up.arrow.down.circle") {
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
		}
#endif
#if os(iOS)
		if #available(iOS 17.0, *) {
			Menu("Sort by", systemImage: "arrow.up.arrow.down.circle") {
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
