import MonsterAnalyzerCore
import SwiftUI

#if os(iOS)
import SwiftUIIntrospect
#endif

struct MonsterView: View {
	@ObservedObject
	private(set) var viewModel: MonsterViewModel

#if !os(watchOS)
	@ViewBuilder
	private var note: some View {
#if os(macOS)
		TextEditor(text: $viewModel.note)
			.font(.body)
			.backport.scrollContentBackground(.hidden)
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
		let background: Color? = Color.systemGroupedBackground
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
						if !headerHidden {
							VStack(alignment: .leading, spacing: 0) {
								Text(verbatim: section.header)
									.font(.system(.subheadline).weight(.medium))
									.padding(.horizontal)
								ScrollablePhysiologyView(viewModel: section)
							}
							.listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
						} else {
							ScrollablePhysiologyView(viewModel: section)
								.listRowInsets(.zero)
						}
#endif
					}
				}

#if os(watchOS)
				if !viewModel.note.isEmpty {
					Section("Note") {
						Text(verbatim: viewModel.note)
					}
				}
#else
				Section("Note") {
					note
				}
#endif
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
		.toolbarItemBackport(alignment: .trailing) {
			if viewModel.isFavorited {
				Button("Remove Favorite", systemImage: "star.fill") {
					viewModel.isFavorited = false
				}
				.help("Remove Favorite")
				.foregroundStyle(.yellow)
			} else {
				Button("Add Favorite", systemImage: "star") {
					viewModel.isFavorited = true
				}
				.help("Add Favorite")
				.foregroundStyle(.yellow)
			}
		}
		.navigationTitle(Text(verbatim: viewModel.name))
	}
}

#Preview {
	let viewModel = MonsterViewModel(id: "gulu_qoo", for: "mockgame")!
	return MonsterView(viewModel: viewModel)
}
