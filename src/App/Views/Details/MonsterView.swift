import MonsterAnalyzerCore
import SwiftUI

struct PhysiologySection: View {
	let physiologies: PhysiologiesViewModel?
	let copyright: String?

	var body: some View {
		MASection("Physiology", background: .separatedInsetGrouped) {
			if let physiologies {
				let headerHidden = physiologies.sections.count <= 1
				ForEach(physiologies.sections) { section in
#if os(macOS)
					PhysiologyView(viewModel: section, headerHidden: headerHidden)
#else
					HeaderScrollablePhysiologyView(viewModel: section,
												   headerHidden: headerHidden)
#endif
				}
			} else {
				ProgressIndicatorView()
#if os(macOS)
					.padding(.vertical, 40)
#else
					.padding(.vertical, 20)
#endif
					.frame(maxWidth: .infinity)
			}
		} footer: {
			if physiologies != nil,
			   let copyright {
				MASectionFooter(copyright)
			}
		}
#if os(iOS) || os(watchOS)
		.ignoreLayoutMargin()
#endif
	}
}

struct MonsterView: View {
	private static let formCoordinateSpace = "form"

	@Environment(\.settings)
	private var settings

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

		PhysiologySection(physiologies: item.physiologies,
						  copyright: item.copyright)

#if os(watchOS)
		NotesSection(note: viewModel.note)
#else
		NotesSection(note: $viewModel.note)
			.disabled(viewModel.isDisabled)
#endif

		if settings?.showInternalInformation ?? false {
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
		// [iOS] Keyboard Dismiss Support
		.block { content in
			switch settings?.keyboardDismissMode {
			case .scroll, .swipe:
				content.backport.scrollViewScrollDismissesKeyboard(settings?.keyboardDismissMode == .scroll ? .immediately : .interactively)
			default:
				content
			}
		}
#endif

#if os(iOS)
		// [iOS] Navigation Bar Background & Additional UI
		.safeAreaInset(edge: .top, spacing: 0) {
			Group {
				if viewModel.items.count > 1 {
					Picker("Mode", selection: $viewModel.selectedItem) {
						ForEach(viewModel.items) { item in
							Text(item.mode.label(.medium)).tag(item as MonsterDataViewModel?)
						}
					}
					.pickerStyle(.segmented)
					.layoutMargin()
					.frame(minHeight: 44.0)
				} else {
					Color.clear.frame(maxWidth: .infinity, maxHeight: 0.0)
				}
			}
			.background(Material.bar.opacity(isBackgroundShown ? 1.0 : 0.0),
						ignoresSafeAreaEdges: [.top, .horizontal])
			.overlay(alignment: .bottom) {
				ChromeShadow()
					.opacity(isBackgroundShown ? 1.0 : 0.0)
					.ignoresSafeArea(.container, edges: .horizontal)
			}
			.animation(.linear(duration: 0.05), value: isBackgroundShown)
		}
		.backport.toolbarBackgroundForNavigationBar(.hidden)
#endif

		// Inject Horizontal Layout Margin
		.injectHorizontalLayoutMargin()

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
					MonsterNavigationBarHeader(name: viewModel.name,
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
		.navigationTitle(viewModel.name)
#endif
#if os(macOS)
		.navigationSubtitle(viewModel.anotherName ?? "")
#endif
	}
}

#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return MonsterView(viewModel: viewModel)
}
