import MonsterAnalyzerCore
import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

struct MonsterView: View {
	@Environment(\.settings)
	private var settings

	@ObservedObject
	private(set) var viewModel: MonsterViewModel

	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

#if !os(watchOS)
	@ViewBuilder
	private var note: some View {
#if os(macOS)
		TextEditor(text: $viewModel.note)
			.font(.body)
			.backport.scrollContentBackground(.hidden, viewType: .textEditor)
#else
		if #available(iOS 16.0, *) {
			TextField(text: $viewModel.note, axis: .vertical) {
				EmptyView()
			}
		} else {
			TextEditor(text: $viewModel.note)
				.font(.body)
				.listRowInsets(.zero)
				.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
					textView.showsVerticalScrollIndicator = false
					textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
				}
		}
#endif
	}
#endif

	var body: some View {
#if os(iOS)
		let background: Color? = .monsterBackground
#else
		let background: Color? = nil
#endif
		StateView(state: viewModel.state, background: background) { data in
			Form {
				if let weakness = data.weakness {
					Section("Weakness") {
						FixedWidthWeaknessView(viewModel: weakness)
					}
				}

				Section("Physiology") {
					let headerHidden = data.physiologies.sections.count <= 1
					ForEach(data.physiologies.sections) { section in
#if os(macOS)
						PhysiologyView(viewModel: section, headerHidden: headerHidden)
#else
						HeaderScrollablePhysiologyView(viewModel: section,
													   headerHidden: headerHidden)
							.listRowInsets(.zero)
#endif
					}
				}

#if os(watchOS)
				if !viewModel.note.isEmpty {
					Section("Notes") {
						Text(viewModel.note)
					}
				}
#else
				Section("Notes") {
					note
				}
#endif

				if settings?.showInternalInformation ?? false {
					DeveloperMonsterView(viewModel: viewModel)
				}
			}
#if os(iOS)
			.backport.scrollDismissesKeyboard(.interactively)
#endif
			.block {
				if #available(iOS 16.0, macOS 13.0, watchOS 9.0, *) {
					$0.formStyle(.grouped)
				} else {
					$0
				}
			}
			.headerProminence(.increased)
		}
#if os(iOS)
		.block { content in
			if !isAccessibilitySize, settings?.showTitle ?? true {
				content.toolbar {
					ToolbarItem(placement: .principal) {
						MonsterNavigationBarHeader(viewModel: viewModel)
							.dynamicTypeSize(...DynamicTypeSize.xxLarge) // Fix iOS 15
					}
				}
			} else {
				content
			}
		}
#endif
		.toolbarItemBackport(alignment: .trailing) {
			FavoriteButton(favorite: $viewModel.isFavorited)
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(Text(viewModel.name))
	}
}

#Preview {
	let viewModel = MonsterViewModel(id: "mockgame:gulu_qoo")!
	return MonsterView(viewModel: viewModel)
}
