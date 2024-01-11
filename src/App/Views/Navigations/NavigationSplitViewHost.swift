import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
struct NavigationSplitViewHost: View {
	@EnvironmentObject
	private var coord: CoordinatorViewModel

	@State
	private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

#if os(iOS)
	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass

	@State
	private var screenWidth: CGFloat = 0
#endif

	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			Sidebar()
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 120, ideal: 150, max: 180)
#endif
		} content: {
			MonsterListColumn()
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 240)
#endif
		} detail: {
			MonsterColumn()
#if os(macOS)
				.navigationSplitViewColumnWidth(min: 480, ideal: 480)
#endif
		}
#if os(iOS)
		.background {
			GeometryReader { proxy in
				Color.clear.onChangeBackport(of: proxy.size.width, initial: true) { _, newValue in
					screenWidth = newValue
				}
			}
		}
		.block { content in
			if screenWidth >= 1000 {
				content.navigationSplitViewStyle(.balanced)
			} else{
				content.navigationSplitViewStyle(.prominentDetail)
			}
		}
		.task {
			if coord.selectedMonsterID != nil {
				columnVisibility = .detailOnly
			}
		}
		.onChange(of: screenWidth) { newValue in
			if screenWidth >= 1000 {
				if columnVisibility == .detailOnly {
					columnVisibility = .doubleColumn
				}
			} else {
				if columnVisibility == .doubleColumn,
				   coord.selectedMonsterID != nil {
					columnVisibility = .detailOnly
				}
			}
		}
		.onChange(of: coord.selectedMonsterID) { newValue in
			guard screenWidth < 1000 else { return }

			if newValue != nil {
				columnVisibility = .detailOnly
			} else {
				columnVisibility = .doubleColumn
			}
		}
#endif
	}
}

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use NavigationSplitViewHost instead")
@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use NavigationSplitViewHost instead")
@available(watchOS, unavailable)
struct NavigationSplitViewHostBackport: View {
	var body: some View {
		NavigationView {
#if os(macOS)
			Sidebar()
				.frame(minWidth: 120, idealWidth: 150)
			MonsterListColumn()
				.frame(minWidth: 150, idealWidth: 200)
#else
			SidebarBackport()
			MonsterListColumnBackport()
#endif

			MonsterColumn()
		}
		.navigationViewStyle(.columns)
	}
}
