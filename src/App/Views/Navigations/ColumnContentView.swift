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
	private var isWideMode: Bool = false
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
		.onWidthChange { screenWidth in
			if screenWidth >= 1024 {
				guard !isWideMode else { return }

				isWideMode = true
				if columnVisibility == .detailOnly {
					columnVisibility = .doubleColumn
				}
			} else {
				guard isWideMode else { return }

				isWideMode = false
				if columnVisibility != .detailOnly,
				   selectedMonsterID != nil {
					columnVisibility = .detailOnly
				}
			}
		}
		.block { content in
			if isWideMode {
				content.navigationSplitViewStyle(.balanced)
			} else{
				content.navigationSplitViewStyle(.prominentDetail)
			}
		}
		.onAppear {
			guard !isWideMode else { return }

			if selectedMonsterID != nil {
				columnVisibility = .detailOnly
			}
		}
		.onChange(of: selectedMonsterID) { newValue in
			guard !isWideMode else { return }

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
#if os(macOS)
				.frame(minWidth: 480, idealWidth: 480)
#endif
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
