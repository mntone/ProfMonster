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
					.padding(.vertical, 20)
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
	@Environment(\.settings)
	private var settings

	@ObservedObject
	private(set) var viewModel: MonsterViewModel

	var body: some View {
		MAForm {
			if let item = viewModel.item {
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
		}
		.headerProminence(.increased)
#if os(iOS)
		.block { content in
			switch settings?.keyboardDismissMode {
			case .scroll, .swipe:
				content.backport.scrollViewScrollDismissesKeyboard(settings?.keyboardDismissMode == .scroll ? .immediately : .interactively)
			default:
				content
			}
		}
		.toolbar {
			ToolbarItem(placement: .principal) {
				MonsterNavigationBarHeader(name: viewModel.name,
										   anotherName: viewModel.anotherName)
			}
		}
#endif
		.toolbarItemBackport(alignment: .trailing) {
			FavoriteButton(favorite: $viewModel.isFavorited)
				.disabled(viewModel.isDisabled)
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name)
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
