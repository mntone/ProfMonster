import MonsterAnalyzerCore
import SwiftUI

struct PhysiologySection: View {
	let physiologies: PhysiologiesViewModel?
	let copyright: String?

	var body: some View {
#if os(macOS)
		let physiologyStyle: MASectionBackgroundStyle = .separatedInsetGrouped(rowInsets: nil)
#else
		let physiologyStyle: MASectionBackgroundStyle = .separatedInsetGrouped(rowInsets: .zero)
#endif
		MASection("Physiology", background: physiologyStyle) {
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
				Text(copyright)
			}
		}
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
					MASection("Weakness", background: .separatedInsetGrouped(rowInsets: nil)) {
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
#if os(iOS)
		.backport.scrollViewScrollDismissesKeyboard(.interactively)
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
