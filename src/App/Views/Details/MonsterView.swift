import MonsterAnalyzerCore
import SwiftUI

struct MonsterView: View {
	private static let formCoordinateSpace = "form"

	let isEntrance: Bool

#if os(iOS)
	@AppStorage(settings: \.keyboardDismissMode)
	private var keyboardDismissMode: KeyboardDismissMode
#endif

	@AppStorage(settings: \.showInternalInformation)
	private var showInternalInformation: Bool

	@Environment(\.accessibilityReduceMotion)
	private var reduceMotion

	@ObservedObject
	private(set) var viewModel: MonsterViewModel

#if os(iOS)
	@State
	private var isBackgroundShown: Bool = false
#endif

	@ViewBuilder
	private func content(_ item: MonsterDataViewModel) -> some View {
#if os(iOS)
		ScrollViewOffsetYDetector(coordinateSpace: Self.formCoordinateSpace, result: $isBackgroundShown) { offsetY in
			offsetY < -4.0
		}
#endif

		if let weakness = item.weakness {
			MASection("Weakness", background: MASectionBackgroundStyle.none) {
				WeaknessView(viewModel: weakness)
			}
		}

		PhysiologySection(physiologies: item.physiologies)

#if os(watchOS)
		NotesSection(note: viewModel.note)
#else
		NotesSection(note: $viewModel.note)
			.disabled(viewModel.isDisabled)
#endif

		if showInternalInformation {
			DeveloperSection(pairs: viewModel.pairs)
		}
	}

	var body: some View {
		Group {
#if os(watchOS)
			TabView(selection: $viewModel.selectedItem) {
				ForEach(viewModel.items) { item in
					MAForm {
						content(item)
					}
					.navigationTitle(item.name)
					.tag(item as MonsterDataViewModel?)
				}
			}
			.tabViewStyle(.page)
#else
			MAForm {
				if let targetViewModel = viewModel.selectedItem {
					content(targetViewModel)
				}
			}
#endif
		}
#if os(iOS)
		.coordinateSpace(name: Self.formCoordinateSpace)
#endif
		.headerProminence(.increased)

#if os(iOS)
		// [iOS] Navigation Bar Background & Additional UI
		.safeAreaInset(edge: .top, spacing: 0) {
			ModeSelection(isBackgroundShown: isBackgroundShown,
						  viewModel: viewModel)
		}
		.backport.toolbarBackgroundForNavigationBar(.hidden)
#endif

#if !os(watchOS)
		// Animation
		.animation(isEntrance || reduceMotion ? nil : .default, value: viewModel.items)
#endif

#if os(iOS)
		// [iOS] Keyboard Dismiss Support
		.block { content in
			switch keyboardDismissMode {
			case .scroll, .swipe:
				content.backport.scrollViewScrollDismissesKeyboard(keyboardDismissMode == .scroll ? .immediately : .interactively)
			default:
				content
			}
		}
#endif

		// ==[ Toolbar ]================
#if os(watchOS)
		// [watchOS] Favorite Button
		.toolbarItemBackport(alignment: .trailing) {
			FavoriteButton(favorite: $viewModel.isFavorited)
				.disabled(viewModel.isDisabled)
		}
#else
		.toolbar {
#if os(iOS)
			// [iOS] Another Name Support in Navigation Bar
			ToolbarItem(placement: .principal) {
				NavigationBarTitleViewSupport {
					MonsterNavigationBarHeader(name: viewModel.title,
											   anotherName: viewModel.anotherName)
				}
			}
#endif

#if os(macOS)
			// [macOS] Mode Picker
			ToolbarItem {
				if viewModel.items.count > 1 {
					Picker("Mode", selection: $viewModel.selectedItem) {
						ForEach(viewModel.items) { item in
							Text(item.mode.label(.medium)).tag(item as MonsterDataViewModel?)
						}
					}
				}
			}
#endif

			// [iOS / macOS] Favorite Button
			ToolbarItem(placement: .primaryAction) {
				FavoriteButton(favorite: $viewModel.isFavorited)
					.disabled(viewModel.isDisabled)
			}
		}
#endif

		// [iOS / macOS] Title Support
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
#if os(iOS) || os(macOS)
		.navigationTitle(viewModel.title)
#endif
#if os(macOS)
		.navigationSubtitle(viewModel.anotherName ?? "")
#endif
	}
}

#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return MonsterView(isEntrance: true, viewModel: viewModel)
}
