import SwiftUI

@available(iOS 16.0, macOS 13.0, *)
@available(watchOS, unavailable)
private struct _NavigationSplitViewHost: View {
#if os(iOS)
	@SceneStorage(CoordinatorUtil.MONSTER_ID_STORAGE_NAME)
	private var selectedMonsterID: String?

	@State
	private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

	@Environment(\.horizontalSizeClass)
	private var horizontalSizeClass

	@State
	private var screenWidth: CGFloat = 0
#endif

	var body: some View {
#if os(macOS)
		NavigationSplitView {
			Sidebar()
				.navigationSplitViewColumnWidth(min: 120, ideal: 150, max: 180)
		} content: {
			MonsterListColumn()
				.navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 240)
		} detail: {
			MonsterColumn()
				.navigationSplitViewColumnWidth(min: 480, ideal: 480)
		}
#else
		NavigationSplitView(columnVisibility: $columnVisibility) {
			Sidebar()
		} content: {
			MonsterListColumn()
		} detail: {
			MonsterColumn()
		}
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
			if selectedMonsterID != nil {
				columnVisibility = .detailOnly
			}
		}
		.onChange(of: screenWidth) { newValue in
			if screenWidth >= 1000 {
				if columnVisibility == .detailOnly {
					columnVisibility = .doubleColumn
				}
			} else {
				if columnVisibility != .detailOnly,
				   selectedMonsterID != nil {
					columnVisibility = .detailOnly
				}
			}
		}
		.onChange(of: selectedMonsterID) { newValue in
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

@available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use _NavigationSplitViewHost instead")
@available(macOS, introduced: 12.0, deprecated: 13.0, message: "Use _NavigationSplitViewHost instead")
@available(watchOS, unavailable)
private struct _NavigationSplitViewHostBackport: View {
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

@available(watchOS, unavailable)
struct ColumnContentView: View {
	var body: some View {
		if #available(iOS 16.0, macOS 13.0, *) {
			_NavigationSplitViewHost()
		} else {
			_NavigationSplitViewHostBackport()
		}
	}
}
