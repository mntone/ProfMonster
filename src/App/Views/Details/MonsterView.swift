import MonsterAnalyzerCore
import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

#if !os(watchOS)

@available(watchOS, unavailable)
struct MonsterTextEditor: View {
	let text: Binding<String>

	var body: some View {
#if os(macOS)
		TextEditor(text: text)
			.font(.body)
			.backport.scrollContentBackground(.hidden, viewType: .textEditor)
#else
		if #available(iOS 16.0, *) {
			TextField(text: text, axis: .vertical) {
				EmptyView()
			}
		} else {
			TextEditor(text: text)
				.font(.body)
				.listRowInsets(.zero)
				.introspect(.textEditor, on: .iOS(.v15)) { (textView: UITextView) in
					textView.showsVerticalScrollIndicator = false
					textView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
				}
		}
#endif
	}
}

#endif

struct MonsterDataView: View {
	let viewModel: MonsterDataViewModel

	var body: some View {
		if let weakness = viewModel.weakness {
			Section("Weakness") {
				FixedWidthWeaknessView(viewModel: weakness)
			}
		}

		Section("Physiology") {
			let headerHidden = viewModel.physiologies.sections.count <= 1
			ForEach(viewModel.physiologies.sections) { section in
#if os(macOS)
				PhysiologyView(viewModel: section, headerHidden: headerHidden)
#else
				HeaderScrollablePhysiologyView(viewModel: section,
											   headerHidden: headerHidden)
#endif
			}
#if !os(macOS)
			.listRowInsets(.zero)
#endif
		}
	}
}

struct MonsterView: View {
	@Environment(\.settings)
	private var settings

	@ObservedObject
	private(set) var viewModel: MonsterViewModel

	@Environment(\.dynamicTypeSize.isAccessibilitySize)
	private var isAccessibilitySize

	var body: some View {
		Form {
			if let item = viewModel.item {
				MonsterDataView(viewModel: item)

#if os(watchOS)
				if !viewModel.note.isEmpty {
					Section("Notes") {
						Text(viewModel.note)
					}
				}
#else
				Section("Notes") {
					MonsterTextEditor(text: $viewModel.note)
						.disabled(viewModel.isDisabled)
				}
#endif

				if settings?.showInternalInformation ?? false {
					DeveloperMonsterView(pairs: viewModel.pairs)
				}
			} else {
				Section {
					Never?.none
				} header: {
					Color.clear
				}
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
#if os(iOS)
		.block { content in
			if !isAccessibilitySize,
			   settings?.showTitle ?? true,
			   let name = viewModel.name,
			   let anotherName = viewModel.anotherName {
				content.toolbar {
					ToolbarItem(placement: .principal) {
						MonsterNavigationBarHeader(name: name, anotherName: anotherName)
							.dynamicTypeSize(...DynamicTypeSize.xxLarge) // Fix iOS 15
					}
				}
			} else {
				content
			}
		}
#endif
		.stateOverlay(viewModel.state)
		.toolbarItemBackport(alignment: .trailing) {
			FavoriteButton(favorite: $viewModel.isFavorited)
				.disabled(viewModel.isDisabled)
		}
#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
#endif
		.navigationTitle(viewModel.name.map(Text.init) ?? Text(verbatim: ""))
	}
}

#Preview {
	let viewModel = MonsterViewModel()
	viewModel.set(id: "mockgame:gulu_qoo")
	return MonsterView(viewModel: viewModel)
}
